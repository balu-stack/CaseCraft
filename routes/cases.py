from fastapi import APIRouter
from pydantic import BaseModel
from database import get_connection
import time

router = APIRouter(prefix="/cases", tags=["Cases"])


class VerifyPatientCaseRequest(BaseModel):
    doctor_id: str
    patient_id: str
    entry_mode: str


def generate_case_id() -> str:
    return f"CASE{int(time.time() * 1000)}"


@router.post("/verify-patient")
def verify_patient(req: VerifyPatientCaseRequest):
    doctor_id = req.doctor_id.strip().upper()
    patient_id = req.patient_id.strip().upper()

    conn = get_connection()
    cur = conn.cursor()

    try:
        cur.execute(
            "SELECT clinic_id FROM doctors WHERE UPPER(TRIM(doctor_id))=%s",
            (doctor_id,)
        )
        doctor_row = cur.fetchone()
        if not doctor_row:
            return {"status": "fail", "message": "Invalid doctor_id"}

        clinic_id = str(doctor_row[0]).strip().upper()

        cur.execute(
            """
            SELECT patient_name
            FROM patients
            WHERE UPPER(TRIM(patient_id))=%s
              AND UPPER(TRIM(clinic_id))=%s
            """,
            (patient_id, clinic_id)
        )
        patient_row = cur.fetchone()

        if not patient_row:
            return {"status": "fail", "message": "Patient not found in your clinic"}

        return {
            "status": "success",
            "patient_id": patient_id,
            "patient_name": patient_row[0]
        }

    finally:
        cur.close()
        conn.close()


@router.post("/start")
def start_case(req: VerifyPatientCaseRequest):
    doctor_id = req.doctor_id.strip().upper()
    patient_id = req.patient_id.strip().upper()
    entry_mode = req.entry_mode.strip().lower()

    conn = get_connection()
    cur = conn.cursor()

    try:
        cur.execute(
            "SELECT clinic_id FROM doctors WHERE UPPER(TRIM(doctor_id))=%s",
            (doctor_id,)
        )
        doctor_row = cur.fetchone()
        if not doctor_row:
            return {"status": "fail", "message": "Invalid doctor_id"}

        clinic_id = str(doctor_row[0]).strip().upper()

        cur.execute(
            """
            SELECT patient_name
            FROM patients
            WHERE UPPER(TRIM(patient_id))=%s
              AND UPPER(TRIM(clinic_id))=%s
            """,
            (patient_id, clinic_id)
        )
        patient_row = cur.fetchone()
        if not patient_row:
            return {"status": "fail", "message": f"Patient not found in your clinic. patient_id={patient_id}, clinic_id={clinic_id}"}

        patient_name = patient_row[0]

        cur.execute(
            """
            SELECT case_id, status
            FROM cases
            WHERE UPPER(TRIM(patient_id))=%s
              AND UPPER(TRIM(clinic_id))=%s
              AND status IN ('draft', 'in_progress')
            ORDER BY created_at DESC
            LIMIT 1
            """,
            (patient_id, clinic_id)
        )
        existing = cur.fetchone()

        if existing:
            case_id, status = existing

            cur.execute(
                """
                UPDATE cases
                SET doctor_id=%s, entry_mode=%s, updated_at=CURRENT_TIMESTAMP
                WHERE case_id=%s
                """,
                (doctor_id, entry_mode, case_id)
            )
            conn.commit()

            return {
                "status": "success",
                "message": "Existing case loaded",
                "case_id": case_id,
                "patient_id": patient_id,
                "patient_name": patient_name,
                "case_status": status,
                "is_existing_case": True
            }

        case_id = generate_case_id()

        cur.execute(
            """
            INSERT INTO cases
            (case_id, patient_id, clinic_id, doctor_id, entry_mode, status)
            VALUES (%s,%s,%s,%s,%s,'draft')
            """,
            (case_id, patient_id, clinic_id, doctor_id, entry_mode)
        )
        conn.commit()

        return {
            "status": "success",
            "message": "New case created",
            "case_id": case_id,
            "patient_id": patient_id,
            "patient_name": patient_name,
            "case_status": "draft",
            "is_existing_case": False
        }

    except Exception as e:
        conn.rollback()
        return {"status": "fail", "message": f"DB error: {str(e)}"}

    finally:
        cur.close()
        conn.close()


@router.get("/doctor/{doctor_id}")
def get_cases_for_doctor(doctor_id: str):
    did = doctor_id.strip().upper()

    conn = get_connection()
    cur = conn.cursor(dictionary=True)

    try:
        cur.execute(
            """
            SELECT
                c.case_id,
                c.patient_id,
                p.patient_name,
                c.status,
                c.entry_mode,
                c.created_at
            FROM cases c
            JOIN patients p ON c.patient_id = p.patient_id
            WHERE UPPER(TRIM(c.doctor_id)) = %s
            ORDER BY c.updated_at DESC, c.created_at DESC
            """,
            (did,)
        )

        rows = cur.fetchall() or []

        cases = []
        for r in rows:
            cases.append({
                "case_id": r["case_id"],
                "patient_id": r["patient_id"],
                "patient_name": r["patient_name"] or "",
                "status": r["status"] or "draft",
                "entry_mode": r["entry_mode"] or "",
                "date": r["created_at"].strftime("%d %b %Y") if r["created_at"] else ""
            })

        return {"status": "success", "cases": cases}

    except Exception as e:
        return {"status": "fail", "message": f"DB error: {str(e)}", "cases": []}

    finally:
        cur.close()
        conn.close()