from fastapi import FastAPI
from routes.Doctor_auth import router as doctor_auth_router
from routes.Clinic_register import router as clinic_register_router
from routes.clinic_auth import router as clinic_auth_router
from routes.Clinic_doctors import router as clinic_doctors_router 
from routes.doctor_forgot_password import router as doctor_forgot_router
from routes.patients import router as patients_router
from routes.speech_parser import router as speech_router
from routes.case_forms import router as case_forms_router
from routes.cases import router as cases_router
from routes.verify_patient import router as verify_patient_router



app = FastAPI()

@app.get("/")
def root():
    return {"message": "CaseCraft backend running"}

app.include_router(doctor_auth_router)
app.include_router(clinic_register_router)
app.include_router(clinic_auth_router)
app.include_router(clinic_doctors_router)
app.include_router(doctor_forgot_router)
app.include_router(patients_router)
app.include_router(speech_router)
app.include_router(case_forms_router)
app.include_router(cases_router)
app.include_router(verify_patient_router)