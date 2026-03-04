class ClinicDoctorAPI {

    static let shared = ClinicDoctorAPI()

    private let baseURL = "http://127.0.0.1:8000"

    func addDoctor(req: AddDoctorRequest) async throws -> AddDoctorResponse {

        guard let url = URL(string: "\(baseURL)/clinic/add-doctor") else {
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

        return try JSONDecoder().decode(AddDoctorResponse.self, from: data)
    }
}