import Foundation

struct AddDoctorRequest: Codable {
    let clinic_id: String
    let doctor_name: String
    let doctor_email: String
    let doctor_phone: String
    let specialization: String
    let password: String
}

struct AddDoctorResponse: Codable {
    let status: String
    let message: String
    let doctor_id: String?
}