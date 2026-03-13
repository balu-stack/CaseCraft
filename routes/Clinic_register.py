from fastapi import APIRouter
from pydantic import BaseModel, EmailStr
from passlib.context import CryptContext
from database import get_connection
import hashlib
import time

router = APIRouter(prefix="/clinic", tags=["Clinic"])

# ✅ FIX: bcrypt_sha256 avoids bcrypt 72-byte limit
pwd_ctx = CryptContext(schemes=["bcrypt_sha256"], deprecated="auto")


class ClinicRegisterRequest(BaseModel):
    clinic_name: str
    clinic_phone: str
    clinic_email: EmailStr
    address: str = ""
    city: str
    state: str
    pincode: str
    password: str


def normalize_phone(phone: str) -> str:
    return "".join(ch for ch in phone if ch.isdigit())


def generate_clinic_id(clinic_name: str, phone_digits: str, email: str) -> str:
    name_part = "".join([c for c in clinic_name.upper() if c.isalpha()])[:3].ljust(3, "X")
    last4 = phone_digits[-4:].rjust(4, "0")
    raw = f"{clinic_name.lower()}|{phone_digits}|{email.lower()}|{time.time_ns()}"
    digest = hashlib.sha256(raw.encode("utf-8")).hexdigest().upper()[:4]
    return f"C-{name_part}-{last4}-{digest}"


@router.post("/register")
def register_clinic(req: ClinicRegisterRequest):
    phone_digits = normalize_phone(req.clinic_phone)
    email = req.clinic_email.strip().lower()

    if len(phone_digits) < 10:
        return {"status": "fail", "message": "Invalid phone number"}

    password_plain = req.password.strip()
    if len(password_plain) < 6:
        return {"status": "fail", "message": "Password must be at least 6 characters"}

    conn = get_connection()
    cur = conn.cursor()

    try:
        cur.execute(
            "SELECT clinic_id FROM clinics WHERE clinic_email=%s OR clinic_phone=%s",
            (email, phone_digits),
        )
        if cur.fetchone():
            return {"status": "fail", "message": "Clinic already exists"}

        clinic_id = None
        for _ in range(5):
            cid = generate_clinic_id(req.clinic_name.strip(), phone_digits, email)
            cur.execute("SELECT clinic_id FROM clinics WHERE clinic_id=%s", (cid,))
            if not cur.fetchone():
                clinic_id = cid
                break

        if not clinic_id:
            return {"status": "fail", "message": "Could not generate Clinic ID. Try again."}

        # ✅ FIX: bcrypt_sha256 (no 72-byte issue)
        password_hash = pwd_ctx.hash(password_plain)

        cur.execute(
            """
            INSERT INTO clinics
            (clinic_id, clinic_name, clinic_phone, clinic_email, address, city, state, pincode, password_hash, is_active)
            VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,TRUE)
            """,
            (
                clinic_id,
                req.clinic_name.strip(),
                phone_digits,
                email,
                req.address.strip(),
                req.city.strip(),
                req.state.strip(),
                req.pincode.strip(),
                password_hash,
            ),
        )
        conn.commit()

        return {"status": "success", "message": "Registered successfully", "clinic_id": clinic_id}

    except Exception as e:
        conn.rollback()
        return {"status": "fail", "message": f"DB error: {str(e)}"}

    finally:
        cur.close()
        conn.close()