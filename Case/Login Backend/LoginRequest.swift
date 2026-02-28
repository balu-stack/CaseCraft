//
//  LoginRequest.swift
//  Case
//
//  Created by SAIL L1 on 27/02/26.
//


import Foundation

struct LoginRequest: Codable {
    let doctor_id: String
    let password: String
}

struct LoginResponse: Codable {
    let status: String
}

class AuthAPI {

    static let shared = AuthAPI()

    private let baseURL = "http://127.0.0.1:8000"

    func login(doctorId: String, password: String) async -> Bool {

        guard let url = URL(string: "\(baseURL)/login") else {
            return false
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = LoginRequest(doctor_id: doctorId, password: password)

        do {
            request.httpBody = try JSONEncoder().encode(body)

            let (data, _) = try await URLSession.shared.data(for: request)

            let response = try JSONDecoder().decode(LoginResponse.self, from: data)

            return response.status == "success"

        } catch {
            print("Login error:", error)
            return false
        }
    }
}