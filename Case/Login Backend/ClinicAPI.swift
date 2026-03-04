final class ClinicAPI {
    static let shared = ClinicAPI()
    private init() {}

    private let baseURL = "http://127.0.0.1:8000"

    func registerClinic(req: ClinicRegisterRequest) async throws -> ClinicRegisterResponse {
        guard let url = URL(string: "\(baseURL)/clinic/register") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(req)

        let (data, response) = try await URLSession.shared.data(for: request)

        if let http = response as? HTTPURLResponse,
           !(200...299).contains(http.statusCode) {
            throw NSError(domain: "HTTP", code: http.statusCode)
        }

        return try JSONDecoder().decode(ClinicRegisterResponse.self, from: data)
    }
}