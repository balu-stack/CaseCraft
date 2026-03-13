from fastapi import APIRouter, Query
from database import get_connection
from models import CreatePatientRequest, CreatePatientResponse

router = APIRouter(prefix="/patient", tags=["Patients"])


def generate_patient_id(clinic_id: str, count: int) -> str:
    clean = "".join(ch for ch in clinic_id.upper() if ch.isalnum())
    suffix = clean[-4:] if len(clean) >= 4 else clean.ljust(4, "X")
    return f"PT{suffix}{count:04d}"


@router.post("/create", response_model=CreatePatientResponse)
def create_patient(req: CreatePatientRequest):
    clinic_id = req.clinic_id.strip()
    patient_name = req.patient_name.strip()
    phone_number = req.phone_number.strip()
    city = (req.city or "").strip()
    state = (req.state or "").strip()

    conn = get_connection()
    cur = conn.cursor()

    try:
        # clinic exists?
        cur.execute("SELECT clinic_id FROM clinics WHERE clinic_id=%s", (clinic_id,))
        if not cur.fetchone():
            return CreatePatientResponse(status="fail", message="Invalid clinic_id")

        # same clinic + same phone => existing patient
        cur.execute(
            "SELECT patient_id FROM patients WHERE clinic_id=%s AND phone_number=%s",
            (clinic_id, phone_number)
        )
        row = cur.fetchone()
        if row:
            return CreatePatientResponse(
                status="success",
                message="Patient already exists",
                patient_id=row[0]
            )

        # generate patient id with collision retry
        patient_id = None
        cur.execute("SELECT COUNT(*) FROM patients WHERE clinic_id=%s", (clinic_id,))
        base_count = cur.fetchone()[0]

        for i in range(1, 6):
            cand = generate_patient_id(clinic_id, base_count + i)
            cur.execute("SELECT patient_id FROM patients WHERE patient_id=%s", (cand,))
            if not cur.fetchone():
                patient_id = cand
                break

        if not patient_id:
            return CreatePatientResponse(status="fail", message="Could not generate patient_id")

        cur.execute(
            """
            INSERT INTO patients (patient_id, clinic_id, patient_name, phone_number, city, state)
            VALUES (%s,%s,%s,%s,%s,%s)
            """,
            (patient_id, clinic_id, patient_name, phone_number, city or None, state or None)
        )
        conn.commit()

        return CreatePatientResponse(
            status="success",
            message="Patient created successfully",
            patient_id=patient_id
        )

    except Exception as e:
        conn.rollback()
        return CreatePatientResponse(status="fail", message=f"DB error: {str(e)}")

    finally:
        cur.close()
        conn.close()


@router.get("/list")
def list_patients(clinic_id: str = Query(...)):
    cid = clinic_id.strip()

    conn = get_connection()
    cur = conn.cursor(dictionary=True)

    try:
        # clinic exists?
        cur.execute("SELECT clinic_id FROM clinics WHERE clinic_id=%s", (cid,))
        if not cur.fetchone():
            return {"status": "fail", "message": "Invalid clinic_id", "patients": []}

        cur.execute(
            """
            SELECT patient_id, patient_name, phone_number, city, state
            FROM patients
            WHERE clinic_id=%s
            ORDER BY created_at DESC
            """,
            (cid,)
        )
        rows = cur.fetchall() or []

        patients = []
        for r in rows:
            patients.append(
                {
                    "patient_id": r["patient_id"],
                    "patient_name": r["patient_name"],
                    "phone_number": r["phone_number"] or "",
                    "city": r["city"] or "",
                    "state": r["state"] or "",
                }
            )

        return {"status": "success", "patients": patients}

    except Exception as e:
        return {"status": "fail", "message": f"DB error: {str(e)}", "patients": []}

    finally:
        cur.close()
        conn.close()