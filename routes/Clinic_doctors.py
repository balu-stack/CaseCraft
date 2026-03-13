from fastapi import APIRouter, Query
from passlib.context import CryptContext
from database import get_connection
from models import AddDoctorRequest, AddDoctorResponse
import time
import secrets
import string

router = APIRouter(prefix="/clinic", tags=["Clinic Doctors"])

pwd_ctx = CryptContext(schemes=["bcrypt_sha256"], deprecated="auto")


def generate_doctor_id(clinic_id: str) -> str:
    # DR + last4(alnum(clinic_id)) + last6(epoch seconds)
    clean = "".join(ch for ch in clinic_id.upper() if ch.isalnum())
    suffix = clean[-4:] if len(clean) >= 4 else clean.ljust(4, "X")
    t = str(int(time.time()))[-6:]
    return f"DR{suffix}{t}"


def generate_password(length: int = 10) -> str:
    # simple password, no hyphens
    chars = string.ascii_letters + string.digits + "@#"
    return "".join(secrets.choice(chars) for _ in range(length))


@router.post("/add-doctor", response_model=AddDoctorResponse)
def add_doctor(req: AddDoctorRequest):
    clinic_id = req.clinic_id.strip()
    doctor_name = req.doctor_name.strip()
    doctor_email = req.doctor_email.strip().lower()
    doctor_phone = (req.doctor_phone or "").strip()
    specialization = (req.specialization or "").strip()

    conn = get_connection()
    cur = conn.cursor()

    try:
        # ✅ check clinic exists
        cur.execute("SELECT clinic_id FROM clinics WHERE clinic_id=%s", (clinic_id,))
        if not cur.fetchone():
            return AddDoctorResponse(status="fail", message="Invalid clinic_id")

        # ✅ check duplicate email
        cur.execute("SELECT doctor_id FROM doctors WHERE doctor_email=%s", (doctor_email,))
        if cur.fetchone():
            return AddDoctorResponse(status="fail", message="Doctor email already exists")

        # ✅ generate doctor_id (retry if collision)
        doctor_id = None
        for _ in range(5):
            did = generate_doctor_id(clinic_id)
            cur.execute("SELECT doctor_id FROM doctors WHERE doctor_id=%s", (did,))
            if not cur.fetchone():
                doctor_id = did
                break

        if not doctor_id:
            return AddDoctorResponse(status="fail", message="Could not generate doctor_id. Try again.")

        # ✅ generate password in backend
        plain_password = generate_password(10)
        password_hash = pwd_ctx.hash(plain_password)

        # ✅ insert doctor
        cur.execute(
            """
            INSERT INTO doctors
            (clinic_id, doctor_id, password_hash, doctor_name, doctor_email, doctor_phone, specialization)
            VALUES (%s,%s,%s,%s,%s,%s,%s)
            """,
            (
                clinic_id,
                doctor_id,
                password_hash,
                doctor_name,
                doctor_email,
                doctor_phone if doctor_phone else None,
                specialization if specialization else None,
            ),
        )
        conn.commit()

        return AddDoctorResponse(
            status="success",
            message="Doctor added successfully",
            doctor_id=doctor_id,
            password=plain_password,  # ✅ return generated password to app
        )

    except Exception as e:
        conn.rollback()
        return AddDoctorResponse(status="fail", message=f"DB error: {str(e)}")

    finally:
        cur.close()
        conn.close()


# ✅ fetch doctors list by clinic_id
@router.get("/doctors")
def get_doctors(clinic_id: str = Query(...)):
    cid = clinic_id.strip()

    conn = get_connection()
    cur = conn.cursor(dictionary=True)

    try:
        cur.execute(
            """
            SELECT doctor_id, doctor_name, doctor_phone, specialization
            FROM doctors
            WHERE clinic_id=%s
            ORDER BY created_at DESC
            """,
            (cid,),
        )
        rows = cur.fetchall() or []

        doctors = []
        for r in rows:
            doctors.append(
                {
                    "doctor_id": r["doctor_id"],
                    "doctor_name": r["doctor_name"],
                    "doctor_phone": r["doctor_phone"] or "",
                    "specialization": r["specialization"] or "",
                    "active": True,  # you don't have is_active column -> always true
                }
            )

        return {"status": "success", "doctors": doctors}

    except Exception as e:
        return {"status": "fail", "message": f"DB error: {str(e)}"}

    finally:
        cur.close()
        conn.close()