//
//  AddDoctorView.swift
//  Case
//
//  Created by SAIL L1 on 23/02/26.
//


import SwiftUI

struct AddDoctorView: View {

    // MARK: - Input Fields
    @State private var doctorName = ""
    @State private var doctorPhone = ""
    @State private var specialization = ""
    @State private var email = ""

    // MARK: - Generated Credentials
    @State private var generatedDoctorId: String? = nil
    @State private var generatedPassword: String? = nil

    @State private var showAlert = false
    @State private var alertMsg = ""

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {

                header

                formCard

                if let did = generatedDoctorId,
                   let pass = generatedPassword {
                    credentialsCard(doctorId: did, password: pass)
                }

                Color.clear.frame(height: 20)
            }
            .padding(.top, 12)
        }
        .navigationTitle("Add Doctor")
        .navigationBarTitleDisplayMode(.inline)
        .alert("CaseCraft", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMsg)
        }
    }

    // MARK: - Header
    private var header: some View {
        HStack(spacing: 12) {
            Image(systemName: "stethoscope.circle.fill")
                .font(.system(size: 30))
                .symbolEffect(.pulse)

            VStack(alignment: .leading) {
                Text("Register Doctor")
                    .font(.title2).bold()
                Text("Add doctor to your clinic")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.horizontal)
    }

    // MARK: - Form Card
    private var formCard: some View {
        VStack(spacing: 14) {

            inputField(title: "Doctor Name", text: $doctorName)
            inputField(title: "Phone Number", text: $doctorPhone, keyboard: .phonePad)
            inputField(title: "Email Address", text: $email, keyboard: .emailAddress)
            inputField(title: "Specialization", text: $specialization)

            Button(action: generateDoctorCredentials) {
                HStack {
                    Image(systemName: "person.badge.key.fill")
                    Text("Generate Doctor ID")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(.primary.opacity(0.3), lineWidth: 1)
                )
            }
            .disabled(!isValid)
            .opacity(isValid ? 1 : 0.5)
        }
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(.primary.opacity(0.15), lineWidth: 1)
        )
        .padding(.horizontal)
    }

    // MARK: - Credentials Card
    private func credentialsCard(doctorId: String, password: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {

            HStack {
                Text("Doctor Credentials")
                    .font(.headline)
                Spacer()
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(.green)
            }

            Divider()

            credentialRow(title: "Doctor ID", value: doctorId)
            credentialRow(title: "Password", value: password)

            Button {
                UIPasteboard.general.string =
                "Doctor ID: \(doctorId)\nPassword: \(password)"
                alertMsg = "Credentials Copied"
                showAlert = true
            } label: {
                HStack {
                    Image(systemName: "doc.on.doc")
                    Text("Copy Credentials")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(.primary.opacity(0.3))
                )
            }
            .padding(.top, 6)

        }
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(.primary.opacity(0.15))
        )
        .padding(.horizontal)
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }

    // MARK: - Helpers

    private func inputField(title: String,
                            text: Binding<String>,
                            keyboard: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.footnote)
                .foregroundStyle(.secondary)

            TextField(title, text: text)
                .keyboardType(keyboard)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(.primary.opacity(0.2))
                )
        }
    }

    private func credentialRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
    }

    private var isValid: Bool {
        doctorName.count > 2 &&
        doctorPhone.count >= 10 &&
        email.contains("@") &&
        specialization.count > 2
    }

    // MARK: - Generation Logic
    private func generateDoctorCredentials() {

        let digits = doctorPhone.filter { $0.isNumber }
        let last4 = String(digits.suffix(4))
        let timePart = String(Int(Date().timeIntervalSince1970) % 100000)

        generatedDoctorId = "D-\(last4)-\(timePart)"
        generatedPassword = randomPassword(length: 10)

        alertMsg = "Doctor Registered Successfully"
        showAlert = true
    }

    private func randomPassword(length: Int) -> String {
        let chars = Array("ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz23456789@#")
        var result = ""
        for _ in 0..<length {
            result.append(chars.randomElement()!)
        }
        return result
    }
}

#Preview {
    NavigationStack {
        AddDoctorView()
    }
}
