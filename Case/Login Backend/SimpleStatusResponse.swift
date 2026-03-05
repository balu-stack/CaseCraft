import Foundation

// MARK: - Common Response
struct SimpleStatusResponse: Codable {
    let status: String
    let message: String
}

// MARK: - Requests
struct SendResetOtpRequest: Codable {
    let email: String
}

struct VerifyResetOtpRequest: Codable {
    let email: String
    let otp: String
}

struct ResetPasswordRequest: Codable {
    let email: String
    let otp: String
    let new_password: String
}

// MARK: - API Client
final class DoctorForgotAPI {

    static let shared = DoctorForgotAPI()
    private init() {}

    private let baseURL = "http://127.0.0.1:8000"

    private func decodeOrThrow(_ data: Data, _ response: URLResponse) throws -> SimpleStatusResponse {
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw NSError(
                domain: "HTTP",
                code: http.statusCode,
                userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode): \(body)"]
            )
        }
        return try JSONDecoder().decode(SimpleStatusResponse.self, from: data)
    }

    func sendOtp(email: String) async throws -> SimpleStatusResponse {
        guard let url = URL(string: "\(baseURL)/doctor/forgot/send-otp") else { throw URLError(.badURL) }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(SendResetOtpRequest(email: email))

        let (data, response) = try await URLSession.shared.data(for: req)
        return try decodeOrThrow(data, response)
    }

    func verifyOtp(email: String, otp: String) async throws -> SimpleStatusResponse {
        guard let url = URL(string: "\(baseURL)/doctor/forgot/verify-otp") else { throw URLError(.badURL) }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(VerifyResetOtpRequest(email: email, otp: otp))

        let (data, response) = try await URLSession.shared.data(for: req)
        return try decodeOrThrow(data, response)
    }

    func resetPassword(email: String, otp: String, newPassword: String) async throws -> SimpleStatusResponse {
        guard let url = URL(string: "\(baseURL)/doctor/forgot/reset-password") else { throw URLError(.badURL) }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(
            ResetPasswordRequest(email: email, otp: otp, new_password: newPassword)
        )

        let (data, response) = try await URLSession.shared.data(for: req)
        return try decodeOrThrow(data, response)
    }
}