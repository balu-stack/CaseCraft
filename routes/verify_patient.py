from fastapi import APIRouter
from pydantic import BaseModel
from database import get_connection

router = APIRouter(prefix="/patients", tags=["Patients"])


class VerifyPatientRequest(BaseModel):
    doctor_id: str
    patient_id: str


@router.post("/verify")
def verify_patient(req: VerifyPatientRequest):

    doctor_id = req.doctor_id.strip().upper()
    patient_id = req.patient_id.strip().upper()

    conn = get_connection()
    cur = conn.cursor()

    try:

        # get doctor clinic
        cur.execute(
            "SELECT clinic_id FROM doctors WHERE UPPER(TRIM(doctor_id))=%s",
            (doctor_id,)
        )

        doctor = cur.fetchone()

        if not doctor:
            return {"status": "fail", "message": "Invalid doctor"}

        clinic_id = doctor[0]

        # check patient in same clinic
        cur.execute(
            """
            SELECT patient_name
            FROM patients
            WHERE UPPER(TRIM(patient_id))=%s
            AND clinic_id=%s
            """,
            (patient_id, clinic_id)
        )

        patient = cur.fetchone()

        if not patient:
            return {"status": "fail", "message": "Patient not found"}

        return {
            "status": "success",
            "patient_id": patient_id,
            "patient_name": patient[0]
        }

    finally:
        cur.close()
        conn.close()