from fastapi import APIRouter
from pydantic import BaseModel
import json
import urllib.request
import urllib.error

router = APIRouter(prefix="/speech", tags=["Speech AI"])

OLLAMA_URL = "http://localhost:11434/api/generate"
OLLAMA_MODEL = "phi3"


class SpeechRequest(BaseModel):
    transcript: str


FULL_EMPTY_RESPONSE = {
    "chief_complaint": "",
    "presenting_illness": "",
    "past_medical_history": "",
    "medication": "",
    "diet": "",
    "smoking": "",
    "pan_chewing": "",
    "gutkha": "",
    "thumb_chewing": "",
    "tongue_thrusting": "",
    "nail_biting": "",
    "lip_biting": "",
    "mouth_breathing": "",
    "treatment_suggestions": "",
    "treatment_notes": "",
    "surgical_contraindications": "",
    "teeth_indicated_for_extraction": "",
    "impacted_teeth_war": "",
    "need_for_orthognathic_surgery": "",
    "type_of_orthognathic_corrections": "",
    "growth_or_swelling_present": "",
    "page3_treatment_suggestions": "",
    "page3_notes": "",
    "missing_teeth": "",
    "edentulousness": "",
    "acp_pdi_classification": "",
    "abutment_adjunct_therapy": "",
    "abutment_inadequate_tooth_structure": "",
    "occlusal_evaluation": "",
    "class_iv_variant": "",
    "sieberts_classification": "",
    "full_mouth_rehab_required": "",
    "head_shape": "",
    "face_shape": "",
    "arch_shape": "",
    "palatal_vault": "",
    "dental_malocclusion": "",
    "skeletal_malocclusion": "",
    "chin_prominence": "",
    "nasolabial_angle": "",
    "lip_examination": "",
    "maxilla_features": "",
    "mandible_features": "",
    "interarch_relation": "",
    "individual_tooth_variations": "",
    "perio_notes": "",
    "facial_form": "",
    "profile_form": "",
    "salivary_gland": "",
    "tm_joint": "",
    "cervical_lymph_nodes": "",
    "others": "",
    "lip": "",
    "gingiva": "",
    "alveolar_mucosa": "",
    "labial_buccal_mucosa": "",
    "tongue": "",
    "floor_of_mouth": "",
    "palate": "",
    "oro_pharynx": "",
    "labial_frenum_upper": "",
    "labial_frenum_lower": "",
    "buccal_frenum_upper_left": "",
    "buccal_frenum_upper_right": "",
    "buccal_frenum_lower_left": "",
    "buccal_frenum_lower_right": "",
    "lingual_frenum": ""
}


def build_schema():
    return {
        "type": "object",
        "properties": {key: {"type": "string"} for key in FULL_EMPTY_RESPONSE.keys()},
        "required": list(FULL_EMPTY_RESPONSE.keys())
    }


def normalize_result(parsed: dict) -> dict:
    normalized = FULL_EMPTY_RESPONSE.copy()

    for key in normalized.keys():
        value = parsed.get(key, "")
        if value is None:
            normalized[key] = ""
        elif isinstance(value, list):
            normalized[key] = ", ".join(str(x).strip() for x in value if str(x).strip())
        else:
            normalized[key] = str(value).strip()

    return normalized


@router.post("/parse")
def parse_speech(req: SpeechRequest):
    schema = build_schema()

    prompt = f"""
You are a dental clinical documentation extractor.

Return ONLY valid JSON matching the provided schema.

Rules:
- Never explain anything.
- Never return markdown.
- If a field is not mentioned, return "".
- Do not invent facts.
- Keep values short and clinically relevant.
- For yes/no fields, use only "yes" or "no".
- For diet, use only "veg" or "nonVeg" when clearly stated.
- For missing_teeth, return tooth numbers like "36" or "16, 26".
- For frenum fields, use only "classI", "classII", or "classIII" if clearly mentioned.
- Use the transcript exactly; do not infer unsupported findings.

Examples:

Transcript:
Patient complains of tooth pain for two days. He has diabetes and takes metformin. Missing tooth 36. Face shape oval.

Expected JSON:
{{
  "chief_complaint": "tooth pain for two days",
  "presenting_illness": "",
  "past_medical_history": "diabetes",
  "medication": "metformin",
  "diet": "",
  "smoking": "",
  "pan_chewing": "",
  "gutkha": "",
  "thumb_chewing": "",
  "tongue_thrusting": "",
  "nail_biting": "",
  "lip_biting": "",
  "mouth_breathing": "",
  "treatment_suggestions": "",
  "treatment_notes": "",
  "surgical_contraindications": "",
  "teeth_indicated_for_extraction": "",
  "impacted_teeth_war": "",
  "need_for_orthognathic_surgery": "",
  "type_of_orthognathic_corrections": "",
  "growth_or_swelling_present": "",
  "page3_treatment_suggestions": "",
  "page3_notes": "",
  "missing_teeth": "36",
  "edentulousness": "",
  "acp_pdi_classification": "",
  "abutment_adjunct_therapy": "",
  "abutment_inadequate_tooth_structure": "",
  "occlusal_evaluation": "",
  "class_iv_variant": "",
  "sieberts_classification": "",
  "full_mouth_rehab_required": "",
  "head_shape": "",
  "face_shape": "oval",
  "arch_shape": "",
  "palatal_vault": "",
  "dental_malocclusion": "",
  "skeletal_malocclusion": "",
  "chin_prominence": "",
  "nasolabial_angle": "",
  "lip_examination": "",
  "maxilla_features": "",
  "mandible_features": "",
  "interarch_relation": "",
  "individual_tooth_variations": "",
  "perio_notes": "",
  "facial_form": "",
  "profile_form": "",
  "salivary_gland": "",
  "tm_joint": "",
  "cervical_lymph_nodes": "",
  "others": "",
  "lip": "",
  "gingiva": "",
  "alveolar_mucosa": "",
  "labial_buccal_mucosa": "",
  "tongue": "",
  "floor_of_mouth": "",
  "palate": "",
  "oro_pharynx": "",
  "labial_frenum_upper": "",
  "labial_frenum_lower": "",
  "buccal_frenum_upper_left": "",
  "buccal_frenum_upper_right": "",
  "buccal_frenum_lower_left": "",
  "buccal_frenum_lower_right": "",
  "lingual_frenum": ""
}}

Transcript:
{req.transcript}
""".strip()

    payload = {
        "model": OLLAMA_MODEL,
        "prompt": prompt,
        "format": schema,
        "stream": False
    }

    try:
        body = json.dumps(payload).encode("utf-8")
        request = urllib.request.Request(
            OLLAMA_URL,
            data=body,
            headers={"Content-Type": "application/json"},
            method="POST"
        )

        with urllib.request.urlopen(request, timeout=120) as response:
            raw = response.read().decode("utf-8")
            outer = json.loads(raw)

        content = outer.get("response", "{}").strip()
        parsed = json.loads(content)
        return normalize_result(parsed)

    except urllib.error.URLError as e:
        fallback = FULL_EMPTY_RESPONSE.copy()
        fallback["others"] = f"Ollama connection error: {str(e)}"
        return fallback
    except Exception as e:
        fallback = FULL_EMPTY_RESPONSE.copy()
        fallback["others"] = f"Speech parse error: {str(e)}"
        return fallback