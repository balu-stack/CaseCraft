import Foundation

struct LoginRequest: Codable {
    let doctor_id: String
    let password: String
}

struct LoginResponse: Codable {
    let status: String
}

final class AuthAPI {

    static let shared = AuthAPI()

    // ✅ Simulator: 127.0.0.1 works if FastAPI is running on your Mac
    // If you run on a real iPhone, you must use your Mac Wi-Fi IP instead.
    private let baseURL = "http://127.0.0.1:8000"

    func login(doctorId: String, password: String) async -> Bool {

        guard let url = URL(string: "\(baseURL)/login") else { return false }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = LoginRequest(doctor_id: doctorId, password: password)

        do {
            req.httpBody = try JSONEncoder().encode(body)

            let (data, response) = try await URLSession.shared.data(for: req)

            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                return false
            }

            let decoded = try JSONDecoder().decode(LoginResponse.self, from: data)
            return decoded.status == "success"

        } catch {
            print("Login error:", error)
            return false
        }
    }
}