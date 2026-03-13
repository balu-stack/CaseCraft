# routes/clinic_auth.py
# ✅ Sends OTP to clinic email + verifies OTP
# ✅ Uses bcrypt_sha256 for password hash verify (matches your register flow)

from fastapi import APIRouter
from pydantic import BaseModel
from database import get_connection
from passlib.context import CryptContext
import secrets
import hashlib
from datetime import datetime, timedelta

# ✅ EMAIL (Gmail SMTP)
import smtplib
from email.message import EmailMessage

router = APIRouter(prefix="/clinic", tags=["Clinic Auth"])

pwd_ctx = CryptContext(schemes=["bcrypt_sha256", "bcrypt"], deprecated="auto")

OTP_TTL_MINUTES = 5

# ----------------------------
# ✅ CHANGE THESE 2 VALUES
# ----------------------------
GMAIL_USER = "balajireddybb135@gmail.com"
GMAIL_APP_PASSWORD = "obisttefmplrikfp"


# ----------------------------
# MODELS
# ----------------------------
class ClinicSendOtpRequest(BaseModel):
    clinic_id: str
    password: str


class ClinicVerifyOtpRequest(BaseModel):
    clinic_id: str
    otp: str


# ----------------------------
# HELPERS
# ----------------------------
def hash_otp(otp: str, clinic_id: str) -> str:
    raw = f"{clinic_id}|{otp}".encode("utf-8")
    return hashlib.sha256(raw).hexdigest()


def generate_otp() -> str:
    return f"{secrets.randbelow(1000000):06d}"


def send_otp_email(to_email: str, otp: str) -> None:
    msg = EmailMessage()
    msg["Subject"] = "CaseCraft Clinic Login OTP"
    msg["From"] = GMAIL_USER
    msg["To"] = to_email
    msg.set_content(
        f"Your CaseCraft OTP is {otp}.\n"
        f"It is valid for {OTP_TTL_MINUTES} minutes.\n\n"
        f"If you did not request this, ignore this email."
    )

    with smtplib.SMTP_SSL("smtp.gmail.com", 465) as smtp:
        smtp.login(GMAIL_USER, GMAIL_APP_PASSWORD)
        smtp.send_message(msg)


# ----------------------------
# ROUTES
# ----------------------------
@router.post("/send-otp")
def clinic_send_otp(req: ClinicSendOtpRequest):
    clinic_id = req.clinic_id.strip()
    password = req.password.strip()

    conn = get_connection()
    cur = conn.cursor()

    try:
        # 1) get stored hash + email
        cur.execute(
            "SELECT clinic_email, password_hash, is_active FROM clinics WHERE clinic_id=%s",
            (clinic_id,),
        )
        row = cur.fetchone()
        if not row:
            return {"status": "fail", "message": "Invalid Clinic ID"}

        clinic_email, password_hash, is_active = row
        if not is_active:
            return {"status": "fail", "message": "Clinic is not active"}

        # 2) verify password
        try:
            ok = pwd_ctx.verify(password, password_hash)
        except Exception as e:
            return {"status": "fail", "message": f"Password hash invalid: {str(e)}"}

        if not ok:
            return {"status": "fail", "message": "Invalid password"}

        # 3) create OTP
        otp = generate_otp()
        otp_h = hash_otp(otp, clinic_id)
        expires_at = datetime.utcnow() + timedelta(minutes=OTP_TTL_MINUTES)

        # mark old OTPs used
        cur.execute(
            "UPDATE clinic_login_otps SET used=TRUE WHERE clinic_id=%s AND used=FALSE",
            (clinic_id,),
        )

        # store OTP hash
        cur.execute(
            """
            INSERT INTO clinic_login_otps (clinic_id, otp_hash, expires_at, used)
            VALUES (%s,%s,%s,FALSE)
            """,
            (clinic_id, otp_h, expires_at),
        )
        conn.commit()

        # 4) send email
        try:
            send_otp_email(to_email=clinic_email, otp=otp)
        except Exception as e:
            # if email fails, invalidate OTP record (optional but cleaner)
            cur.execute(
                "UPDATE clinic_login_otps SET used=TRUE WHERE clinic_id=%s AND used=FALSE",
                (clinic_id,),
            )
            conn.commit()
            return {"status": "fail", "message": f"Email send failed: {str(e)}"}

        return {"status": "success", "message": "OTP sent to registered email"}

    except Exception as e:
        conn.rollback()
        return {"status": "fail", "message": f"DB error: {str(e)}"}

    finally:
        cur.close()
        conn.close()


@router.post("/verify-otp")
def clinic_verify_otp(req: ClinicVerifyOtpRequest):
    clinic_id = req.clinic_id.strip()
    otp = req.otp.strip()

    if len(otp) != 6 or not otp.isdigit():
        return {"status": "fail", "message": "Invalid OTP format"}

    otp_h = hash_otp(otp, clinic_id)

    conn = get_connection()
    cur = conn.cursor()

    try:
        # latest unused OTP
        cur.execute(
            """
            SELECT id, otp_hash, expires_at FROM clinic_login_otps
            WHERE clinic_id=%s AND used=FALSE
            ORDER BY created_at DESC
            LIMIT 1
            """,
            (clinic_id,),
        )
        row = cur.fetchone()
        if not row:
            return {"status": "fail", "message": "OTP not found. Please request OTP again."}

        otp_id, db_otp_hash, expires_at = row

        # expiry check
        if datetime.utcnow() > expires_at:
            cur.execute("UPDATE clinic_login_otps SET used=TRUE WHERE id=%s", (otp_id,))
            conn.commit()
            return {"status": "fail", "message": "OTP expired. Please request OTP again."}

        # match
        if db_otp_hash != otp_h:
            return {"status": "fail", "message": "Wrong OTP"}

        # mark used
        cur.execute("UPDATE clinic_login_otps SET used=TRUE WHERE id=%s", (otp_id,))
        conn.commit()

        return {"status": "success", "message": "Login successful"}

    except Exception as e:
        conn.rollback()
        return {"status": "fail", "message": f"DB error: {str(e)}"}

    finally:
        cur.close()
        conn.close()