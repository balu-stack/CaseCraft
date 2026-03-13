from pydantic import BaseModel, EmailStr
from typing import Optional

class LoginRequest(BaseModel):
    doctor_id: str
    password: str

class SimpleStatus(BaseModel):
    status: str
    message: Optional[str] = None

class AddDoctorRequest(BaseModel):
    clinic_id: str
    doctor_name: str
    doctor_email: EmailStr
    doctor_phone: Optional[str] = None
    specialization: Optional[str] = None 

class AddDoctorResponse(BaseModel):
    status: str
    message: str
    doctor_id: Optional[str] = None
    password: str | None = None 

class ClinicLoginRequest(BaseModel):
    clinic_id: str
    password: str

class CreatePatientRequest(BaseModel):
    clinic_id: str
    patient_name: str
    phone_number: str
    city: Optional[str] = None
    state: Optional[str] = None

class CreatePatientResponse(BaseModel):
    status: str
    message: str
    patient_id: Optional[str] = None

class SaveCaseFormRequest(BaseModel):
    case_id: str

    # Page 1
    chief_complaint: Optional[str] = None
    presenting_illness: Optional[str] = None
    past_medical_history: Optional[str] = None
    medication: Optional[str] = None

    diet: Optional[str] = None
    smoking: Optional[str] = None
    pan_chewing: Optional[str] = None
    gutkha: Optional[str] = None
    thumb_chewing: Optional[str] = None
    tongue_thrusting: Optional[str] = None
    nail_biting: Optional[str] = None
    lip_biting: Optional[str] = None
    mouth_breathing: Optional[str] = None

    # Page 2
    treatment_suggestions: Optional[str] = None
    treatment_notes: Optional[str] = None

    # Page 3
    surgical_contraindications: Optional[str] = None
    teeth_indicated_for_extraction: Optional[str] = None
    impacted_teeth_war: Optional[str] = None
    need_for_orthognathic_surgery: Optional[str] = None
    type_of_orthognathic_corrections: Optional[str] = None
    growth_or_swelling_present: Optional[str] = None
    page3_treatment_suggestions: Optional[str] = None
    page3_notes: Optional[str] = None

    # Page 4
    missing_teeth: Optional[str] = None
    edentulousness: Optional[str] = None
    acp_pdi_classification: Optional[str] = None
    abutment_adjunct_therapy: Optional[str] = None
    abutment_inadequate_tooth_structure: Optional[str] = None
    occlusal_evaluation: Optional[str] = None
    class_iv_variant: Optional[str] = None
    sieberts_classification: Optional[str] = None
    full_mouth_rehab_required: Optional[str] = None

    # Page 5
    head_shape: Optional[str] = None
    face_shape: Optional[str] = None
    arch_shape: Optional[str] = None
    palatal_vault: Optional[str] = None
    dental_malocclusion: Optional[str] = None
    skeletal_malocclusion: Optional[str] = None
    chin_prominence: Optional[str] = None
    nasolabial_angle: Optional[str] = None
    lip_examination: Optional[str] = None
    maxilla_features: Optional[str] = None
    mandible_features: Optional[str] = None
    interarch_relation: Optional[str] = None
    individual_tooth_variations: Optional[str] = None

    # Page 6
    perio_notes: Optional[str] = None

    # Page 7
    facial_form: Optional[str] = None
    profile_form: Optional[str] = None
    salivary_gland: Optional[str] = None
    tm_joint: Optional[str] = None
    cervical_lymph_nodes: Optional[str] = None
    others: Optional[str] = None

    lip: Optional[str] = None
    gingiva: Optional[str] = None
    alveolar_mucosa: Optional[str] = None
    labial_buccal_mucosa: Optional[str] = None
    tongue: Optional[str] = None
    floor_of_mouth: Optional[str] = None
    palate: Optional[str] = None
    oro_pharynx: Optional[str] = None

    labial_frenum_upper: Optional[str] = None
    labial_frenum_lower: Optional[str] = None
    buccal_frenum_upper_left: Optional[str] = None
    buccal_frenum_upper_right: Optional[str] = None
    buccal_frenum_lower_left: Optional[str] = None
    buccal_frenum_lower_right: Optional[str] = None

    lingual_frenum: Optional[str] = None


class SimpleCaseFormResponse(BaseModel):
    status: str
    message: str