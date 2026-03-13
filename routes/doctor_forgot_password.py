from fastapi import APIRouter
from pydantic import BaseModel, EmailStr
from passlib.context import CryptContext
from database import get_connection
from datetime import datetime, timedelta
import hashlib
import secrets

# ✅ use your real email sender
from email_service import send_email

# IMPORTANT: support BOTH hashes
pwd_ctx = CryptContext(schemes=["bcrypt_sha256", "bcrypt"], deprecated="auto")

router = APIRouter(prefix="/doctor", tags=["Doctor Forgot Password"])

OTP_TTL_MINUTES = 5


# ---------- Models ----------
class SendResetOtpRequest(BaseModel):
    email: EmailStr


class VerifyResetOtpRequest(BaseModel):
    email: EmailStr
    otp: str


class ResetPasswordRequest(BaseModel):
    email: EmailStr
    otp: str
    new_password: str


# ---------- Helpers ----------
def generate_otp() -> str:
    return f"{secrets.randbelow(1000000):06d}"


def hash_otp(otp: str, doctor_id: str) -> str:
    raw = f"{doctor_id}|{otp}".encode("utf-8")
    return hashlib.sha256(raw).hexdigest()


# ---------- Routes ----------
@router.post("/forgot/send-otp")
def send_reset_otp(req: SendResetOtpRequest):
    email = req.email.strip().lower()

    conn = get_connection()
    cur = conn.cursor()

    try:
        # 1) find doctor by email
        cur.execute("SELECT doctor_id FROM doctors WHERE doctor_email=%s", (email,))
        row = cur.fetchone()

        # SECURITY: don’t reveal if email exists
        if not row:
            return {"status": "success", "message": "If email exists, OTP has been sent."}

        doctor_id = row[0]

        # 2) generate OTP + store hash
        otp = generate_otp()
        otp_h = hash_otp(otp, doctor_id)
        expires_at = datetime.utcnow() + timedelta(minutes=OTP_TTL_MINUTES)

        # invalidate old otps
        cur.execute(
            "UPDATE doctor_password_otps SET used=TRUE WHERE doctor_id=%s AND used=FALSE",
            (doctor_id,),
        )

        cur.execute(
            """
            INSERT INTO doctor_password_otps (doctor_id, otp_hash, expires_at, used)
            VALUES (%s,%s,%s,FALSE)
            """,
            (doctor_id, otp_h, expires_at),
        )
        conn.commit()

        # 3) send email (REAL SMTP)
        send_email(
            to_email=email,
            subject="CaseCraft: Password Reset OTP",
            body=f"Your OTP is {otp}. Valid for {OTP_TTL_MINUTES} minutes.",
        )

        return {"status": "success", "message": "OTP sent to your email"}

    except Exception as e:
        conn.rollback()
        return {"status": "fail", "message": f"DB error: {str(e)}"}

    finally:
        cur.close()
        conn.close()


@router.post("/forgot/verify-otp")
def verify_reset_otp(req: VerifyResetOtpRequest):
    email = req.email.strip().lower()
    otp = req.otp.strip()

    if len(otp) != 6 or not otp.isdigit():
        return {"status": "fail", "message": "Invalid OTP format"}

    conn = get_connection()
    cur = conn.cursor()

    try:
        # get doctor_id
        cur.execute("SELECT doctor_id FROM doctors WHERE doctor_email=%s", (email,))
        row = cur.fetchone()
        if not row:
            return {"status": "fail", "message": "Invalid OTP"}

        doctor_id = row[0]
        otp_h = hash_otp(otp, doctor_id)

        # latest unused otp
        cur.execute(
            """
            SELECT id, otp_hash, expires_at FROM doctor_password_otps
            WHERE doctor_id=%s AND used=FALSE
            ORDER BY created_at DESC
            LIMIT 1
            """,
            (doctor_id,),
        )
        r = cur.fetchone()
        if not r:
            return {"status": "fail", "message": "OTP not found. Please request again."}

        otp_id, stored_hash, expires_at = r

        # expiry check
        if datetime.utcnow() > expires_at:
            cur.execute("UPDATE doctor_password_otps SET used=TRUE WHERE id=%s", (otp_id,))
            conn.commit()
            return {"status": "fail", "message": "OTP expired. Please request again."}

        if stored_hash != otp_h:
            return {"status": "fail", "message": "Wrong OTP"}

        return {"status": "success", "message": "OTP verified"}

    except Exception as e:
        return {"status": "fail", "message": f"DB error: {str(e)}"}

    finally:
        cur.close()
        conn.close()


@router.post("/forgot/reset-password")
def reset_password(req: ResetPasswordRequest):
    email = req.email.strip().lower()
    otp = req.otp.strip()
    new_password = req.new_password.strip()

    if len(new_password) < 6:
        return {"status": "fail", "message": "Password must be at least 6 characters"}

    if len(otp) != 6 or not otp.isdigit():
        return {"status": "fail", "message": "Invalid OTP"}

    conn = get_connection()
    cur = conn.cursor()

    try:
        # doctor_id
        cur.execute("SELECT doctor_id FROM doctors WHERE doctor_email=%s", (email,))
        row = cur.fetchone()
        if not row:
            return {"status": "fail", "message": "Invalid OTP"}

        doctor_id = row[0]
        otp_h = hash_otp(otp, doctor_id)

        # latest unused otp
        cur.execute(
            """
            SELECT id, otp_hash, expires_at FROM doctor_password_otps
            WHERE doctor_id=%s AND used=FALSE
            ORDER BY created_at DESC
            LIMIT 1
            """,
            (doctor_id,),
        )
        r = cur.fetchone()
        if not r:
            return {"status": "fail", "message": "OTP not found. Please request again."}

        otp_id, stored_hash, expires_at = r

        if datetime.utcnow() > expires_at:
            cur.execute("UPDATE doctor_password_otps SET used=TRUE WHERE id=%s", (otp_id,))
            conn.commit()
            return {"status": "fail", "message": "OTP expired. Please request again."}

        if stored_hash != otp_h:
            return {"status": "fail", "message": "Wrong OTP"}

        # mark used + update password
        new_hash = pwd_ctx.hash(new_password)

        cur.execute("UPDATE doctor_password_otps SET used=TRUE WHERE id=%s", (otp_id,))
        cur.execute("UPDATE doctors SET password_hash=%s WHERE doctor_id=%s", (new_hash, doctor_id))
        conn.commit()

        return {"status": "success", "message": "Password updated successfully"}

    except Exception as e:
        conn.rollback()
        return {"status": "fail", "message": f"DB error: {str(e)}"}

    finally:
        cur.close()
        conn.close()