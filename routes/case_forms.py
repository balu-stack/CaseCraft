from fastapi import APIRouter
from database import get_connection
from models import SaveCaseFormRequest, SimpleCaseFormResponse

router = APIRouter(prefix="/cases", tags=["Case Forms"])


@router.post("/save-form", response_model=SimpleCaseFormResponse)
def save_case_form(req: SaveCaseFormRequest):
    conn = get_connection()
    cur = conn.cursor()

    try:
        # Ensure case exists
        cur.execute("SELECT case_id FROM cases WHERE case_id=%s", (req.case_id.strip(),))
        if not cur.fetchone():
            return SimpleCaseFormResponse(status="fail", message="Invalid case_id")

        # Upsert into case_forms
        cur.execute(
            """
            INSERT INTO case_forms (
                case_id,

                chief_complaint, presenting_illness, past_medical_history, medication,
                diet, smoking, pan_chewing, gutkha, thumb_chewing, tongue_thrusting, nail_biting, lip_biting, mouth_breathing,

                treatment_suggestions, treatment_notes,

                surgical_contraindications, teeth_indicated_for_extraction, impacted_teeth_war,
                need_for_orthognathic_surgery, type_of_orthognathic_corrections, growth_or_swelling_present,
                page3_treatment_suggestions, page3_notes,

                missing_teeth, edentulousness, acp_pdi_classification, abutment_adjunct_therapy,
                abutment_inadequate_tooth_structure, occlusal_evaluation, class_iv_variant,
                sieberts_classification, full_mouth_rehab_required,

                head_shape, face_shape, arch_shape, palatal_vault, dental_malocclusion,
                skeletal_malocclusion, chin_prominence, nasolabial_angle, lip_examination,
                maxilla_features, mandible_features, interarch_relation, individual_tooth_variations,

                perio_notes,

                facial_form, profile_form, salivary_gland, tm_joint, cervical_lymph_nodes, others,
                lip, gingiva, alveolar_mucosa, labial_buccal_mucosa, tongue, floor_of_mouth, palate, oro_pharynx,

                labial_frenum_upper, labial_frenum_lower, buccal_frenum_upper_left,
                buccal_frenum_upper_right, buccal_frenum_lower_left, buccal_frenum_lower_right,
                lingual_frenum
            )
            VALUES (
                %s,

                %s,%s,%s,%s,
                %s,%s,%s,%s,%s,%s,%s,%s,%s,

                %s,%s,

                %s,%s,%s,
                %s,%s,%s,
                %s,%s,

                %s,%s,%s,%s,
                %s,%s,%s,
                %s,%s,

                %s,%s,%s,%s,%s,
                %s,%s,%s,%s,
                %s,%s,%s,%s,

                %s,

                %s,%s,%s,%s,%s,%s,
                %s,%s,%s,%s,%s,%s,%s,%s,

                %s,%s,%s,
                %s,%s,%s,
                %s
            )
            ON DUPLICATE KEY UPDATE

                chief_complaint=VALUES(chief_complaint),
                presenting_illness=VALUES(presenting_illness),
                past_medical_history=VALUES(past_medical_history),
                medication=VALUES(medication),

                diet=VALUES(diet),
                smoking=VALUES(smoking),
                pan_chewing=VALUES(pan_chewing),
                gutkha=VALUES(gutkha),
                thumb_chewing=VALUES(thumb_chewing),
                tongue_thrusting=VALUES(tongue_thrusting),
                nail_biting=VALUES(nail_biting),
                lip_biting=VALUES(lip_biting),
                mouth_breathing=VALUES(mouth_breathing),

                treatment_suggestions=VALUES(treatment_suggestions),
                treatment_notes=VALUES(treatment_notes),

                surgical_contraindications=VALUES(surgical_contraindications),
                teeth_indicated_for_extraction=VALUES(teeth_indicated_for_extraction),
                impacted_teeth_war=VALUES(impacted_teeth_war),
                need_for_orthognathic_surgery=VALUES(need_for_orthognathic_surgery),
                type_of_orthognathic_corrections=VALUES(type_of_orthognathic_corrections),
                growth_or_swelling_present=VALUES(growth_or_swelling_present),
                page3_treatment_suggestions=VALUES(page3_treatment_suggestions),
                page3_notes=VALUES(page3_notes),

                missing_teeth=VALUES(missing_teeth),
                edentulousness=VALUES(edentulousness),
                acp_pdi_classification=VALUES(acp_pdi_classification),
                abutment_adjunct_therapy=VALUES(abutment_adjunct_therapy),
                abutment_inadequate_tooth_structure=VALUES(abutment_inadequate_tooth_structure),
                occlusal_evaluation=VALUES(occlusal_evaluation),
                class_iv_variant=VALUES(class_iv_variant),
                sieberts_classification=VALUES(sieberts_classification),
                full_mouth_rehab_required=VALUES(full_mouth_rehab_required),

                head_shape=VALUES(head_shape),
                face_shape=VALUES(face_shape),
                arch_shape=VALUES(arch_shape),
                palatal_vault=VALUES(palatal_vault),
                dental_malocclusion=VALUES(dental_malocclusion),
                skeletal_malocclusion=VALUES(skeletal_malocclusion),
                chin_prominence=VALUES(chin_prominence),
                nasolabial_angle=VALUES(nasolabial_angle),
                lip_examination=VALUES(lip_examination),
                maxilla_features=VALUES(maxilla_features),
                mandible_features=VALUES(mandible_features),
                interarch_relation=VALUES(interarch_relation),
                individual_tooth_variations=VALUES(individual_tooth_variations),

                perio_notes=VALUES(perio_notes),

                facial_form=VALUES(facial_form),
                profile_form=VALUES(profile_form),
                salivary_gland=VALUES(salivary_gland),
                tm_joint=VALUES(tm_joint),
                cervical_lymph_nodes=VALUES(cervical_lymph_nodes),
                others=VALUES(others),

                lip=VALUES(lip),
                gingiva=VALUES(gingiva),
                alveolar_mucosa=VALUES(alveolar_mucosa),
                labial_buccal_mucosa=VALUES(labial_buccal_mucosa),
                tongue=VALUES(tongue),
                floor_of_mouth=VALUES(floor_of_mouth),
                palate=VALUES(palate),
                oro_pharynx=VALUES(oro_pharynx),

                labial_frenum_upper=VALUES(labial_frenum_upper),
                labial_frenum_lower=VALUES(labial_frenum_lower),
                buccal_frenum_upper_left=VALUES(buccal_frenum_upper_left),
                buccal_frenum_upper_right=VALUES(buccal_frenum_upper_right),
                buccal_frenum_lower_left=VALUES(buccal_frenum_lower_left),
                buccal_frenum_lower_right=VALUES(buccal_frenum_lower_right),
                lingual_frenum=VALUES(lingual_frenum),
                updated_at=CURRENT_TIMESTAMP
            """,
            (
                req.case_id,

                req.chief_complaint, req.presenting_illness, req.past_medical_history, req.medication,
                req.diet, req.smoking, req.pan_chewing, req.gutkha, req.thumb_chewing, req.tongue_thrusting, req.nail_biting, req.lip_biting, req.mouth_breathing,

                req.treatment_suggestions, req.treatment_notes,

                req.surgical_contraindications, req.teeth_indicated_for_extraction, req.impacted_teeth_war,
                req.need_for_orthognathic_surgery, req.type_of_orthognathic_corrections, req.growth_or_swelling_present,
                req.page3_treatment_suggestions, req.page3_notes,

                req.missing_teeth, req.edentulousness, req.acp_pdi_classification, req.abutment_adjunct_therapy,
                req.abutment_inadequate_tooth_structure, req.occlusal_evaluation, req.class_iv_variant,
                req.sieberts_classification, req.full_mouth_rehab_required,

                req.head_shape, req.face_shape, req.arch_shape, req.palatal_vault, req.dental_malocclusion,
                req.skeletal_malocclusion, req.chin_prominence, req.nasolabial_angle, req.lip_examination,
                req.maxilla_features, req.mandible_features, req.interarch_relation, req.individual_tooth_variations,

                req.perio_notes,

                req.facial_form, req.profile_form, req.salivary_gland, req.tm_joint, req.cervical_lymph_nodes, req.others,
                req.lip, req.gingiva, req.alveolar_mucosa, req.labial_buccal_mucosa, req.tongue, req.floor_of_mouth, req.palate, req.oro_pharynx,

                req.labial_frenum_upper, req.labial_frenum_lower, req.buccal_frenum_upper_left,
                req.buccal_frenum_upper_right, req.buccal_frenum_lower_left, req.buccal_frenum_lower_right,
                req.lingual_frenum
            )
        )
        cur.execute(
            """
                UPDATE cases
                SET status='completed', updated_at=CURRENT_TIMESTAMP
                WHERE case_id=%s
            """,
            (req.case_id,)
        )

        conn.commit()
        return SimpleCaseFormResponse(status="success", message="Case form saved successfully")

    except Exception as e:
        conn.rollback()
        return SimpleCaseFormResponse(status="fail", message=f"DB error: {str(e)}")

    finally:
        cur.close()
        conn.close()

@router.get("/form/{case_id}")
def get_case_form(case_id: str):
    conn = get_connection()
    cur = conn.cursor(dictionary=True)

    try:
        cur.execute(
            "SELECT * FROM case_forms WHERE case_id=%s",
            (case_id.strip(),)
        )

        row = cur.fetchone()

        if not row:
            return {
                "status": "fail",
                "message": "Case form not found"
            }

        return {
            "status": "success",
            "form": row
        }

    except Exception as e:
        return {"status": "fail", "message": str(e)}

    finally:
        cur.close()
        conn.close()