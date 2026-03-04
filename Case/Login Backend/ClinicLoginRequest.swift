import Foundation

struct ClinicLoginRequest: Codable {
    let clinic_id: String
    let password: String
}

struct ClinicLoginResponse: Codable {
    let status: String
    let message: String
}

final class ClinicAuthAPI {
    static let shared = ClinicAuthAPI()
    private init() {}

    private let baseURL = "http://127.0.0.1:8000"

    func login(clinicId: String, password: String) async throws -> ClinicLoginResponse {
        guard let url = URL(string: "\(baseURL)/clinic/login") else {
            throw URLError(.badURL)
        }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(
            ClinicLoginRequest(clinic_id: clinicId, password: password)
        )

        let (data, response) = try await URLSession.shared.data(for: req)

        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw NSError(domain: "HTTP", code: http.statusCode)
        }

        return try JSONDecoder().decode(ClinicLoginResponse.self, from: data)
    }
}