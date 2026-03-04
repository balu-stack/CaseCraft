import Foundation

struct ClinicSendOtpRequest: Codable {
    let clinic_id: String
    let password: String
}

struct ClinicVerifyOtpRequest: Codable {
    let clinic_id: String
    let otp: String
}

struct ClinicOtpResponse: Codable {
    let status: String
    let message: String
}

final class ClinicOTPAPI {
    static let shared = ClinicOTPAPI()
    private init() {}

    private let baseURL = "http://127.0.0.1:8000"

    func sendOtp(clinicId: String, password: String) async throws -> ClinicOtpResponse {
        guard let url = URL(string: "\(baseURL)/clinic/send-otp") else { throw URLError(.badURL) }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(ClinicSendOtpRequest(clinic_id: clinicId, password: password))

        let (data, response) = try await URLSession.shared.data(for: req)
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw NSError(domain: "HTTP", code: http.statusCode)
        }
        return try JSONDecoder().decode(ClinicOtpResponse.self, from: data)
    }

    func verifyOtp(clinicId: String, otp: String) async throws -> ClinicOtpResponse {
        guard let url = URL(string: "\(baseURL)/clinic/verify-otp") else { throw URLError(.badURL) }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(ClinicVerifyOtpRequest(clinic_id: clinicId, otp: otp))

        let (data, response) = try await URLSession.shared.data(for: req)
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw NSError(domain: "HTTP", code: http.statusCode)
        }
        return try JSONDecoder().decode(ClinicOtpResponse.self, from: data)
    }
}