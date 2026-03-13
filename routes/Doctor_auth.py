from fastapi import APIRouter
from passlib.context import CryptContext

from database import get_connection
from models import LoginRequest, SimpleStatus

router = APIRouter(prefix="", tags=["Doctor Auth"])

# ✅ FIX: support bcrypt_sha256 (new) + bcrypt (old)
pwd_context = CryptContext(
    schemes=["bcrypt_sha256", "bcrypt"],
    deprecated="auto"
)

@router.post("/login", response_model=SimpleStatus)
def login(req: LoginRequest):
    conn = get_connection()
    cur = conn.cursor()

    cur.execute(
        "SELECT password_hash FROM doctors WHERE doctor_id=%s",
        (req.doctor_id.strip(),)
    )
    row = cur.fetchone()

    cur.close()
    conn.close()

    if not row:
        return {"status": "fail", "message": "Invalid Doctor ID or Password"}

    stored_hash = row[0]
    try:
        ok = pwd_context.verify(req.password.strip(), stored_hash)
    except Exception:
        return {"status": "fail", "message": "Password hash is invalid (check bcrypt setup)"}

    if not ok:
        return {"status": "fail", "message": "Invalid Doctor ID or Password"}

    return {"status": "success", "message": "Login success"}