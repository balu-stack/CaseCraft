import Foundation

struct CreatePatientRequest: Codable {
    let clinic_id: String
    let patient_name: String
    let phone_number: String
    let city: String?
    let state: String?
}

struct CreatePatientResponse: Codable {
    let status: String
    let message: String
    let patient_id: String?
}

final class PatientAPI {
    static let shared = PatientAPI()
    private init() {}

    private let baseURL = "http://127.0.0.1:8000"

    func createPatient(req: CreatePatientRequest) async throws -> CreatePatientResponse {
        guard let url = URL(string: "\(baseURL)/patient/create") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 30
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(req)

        let (data, response) = try await URLSession.shared.data(for: request)

        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw NSError(
                domain: "HTTP",
                code: http.statusCode,
                userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode): \(body)"]
            )
        }

        return try JSONDecoder().decode(CreatePatientResponse.self, from: data)
    }
}