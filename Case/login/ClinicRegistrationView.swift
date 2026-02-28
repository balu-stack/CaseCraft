//
//  ClinicRegistrationView.swift
//  Case
//
//  Minimal + Better UI version
//

import SwiftUI

struct ClinicRegistrationView: View {

    // ✅ Minimal required fields
    @State private var clinicName = ""
    @State private var ownerName = ""
    @State private var phone = ""
    @State private var email = ""

    enum Plan: String, CaseIterable {
        case monthly = "Monthly"
        case yearly = "Yearly"
    }
    @State private var selectedPlan: Plan = .monthly

    @State private var agree = false
    @State private var isSubmitting = false
    @State private var showAlert = false
    @State private var alertMsg = ""

    var body: some View {
        ZStack {

            // Premium background (same theme)
            LinearGradient(
                colors: [
                    Color(red: 24/255, green: 28/255, blue: 66/255),
                    Color(red: 45/255, green: 88/255, blue: 166/255),
                    Color(red: 80/255, green: 180/255, blue: 200/255)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 260, height: 260)
                .blur(radius: 60)
                .offset(x: -120, y: -220)

            Circle()
                .fill(Color.cyan.opacity(0.12))
                .frame(width: 220, height: 220)
                .blur(radius: 70)
                .offset(x: 140, y: 260)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 18) {

                    // Header
                    VStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(.white.opacity(0.18))
                                .frame(width: 90, height: 90)

                            Image(systemName: "building.2.crop.circle")
                                .font(.system(size: 36, weight: .semibold))
                                .foregroundColor(.white)
                        }

                        Text("Register Clinic")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        Text("Enter basic details and complete payment to activate your Clinic ID.")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.85))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 12)
                    }
                    .padding(.top, 18)

                    // Card
                    VStack(spacing: 14) {

                        // Minimal fields
                        glassField(icon: "cross.case.fill", placeholder: "Clinic Name", text: $clinicName)
                        glassField(icon: "person.fill", placeholder: "Owner / Manager Name", text: $ownerName)
                        glassField(icon: "phone.fill", placeholder: "Phone Number", text: $phone, keyboard: .phonePad, autocap: .never)
                        glassField(icon: "envelope.fill", placeholder: "Clinic Email (OTP & receipts)", text: $email, keyboard: .emailAddress, autocap: .never)

                        // Plan (clean segmented look)
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Choose Plan")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.95))

                            HStack(spacing: 10) {
                                ForEach(Plan.allCases, id: \.self) { plan in
                                    Button {
                                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                            selectedPlan = plan
                                        }
                                    } label: {
                                        Text(plan.rawValue)
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .foregroundColor(selectedPlan == plan ? .black : .white)
                                            .background(selectedPlan == plan ? .white : .white.opacity(0.14))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                                    .stroke(.white.opacity(selectedPlan == plan ? 0 : 0.25), lineWidth: 1)
                                            )
                                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }

                            Text(selectedPlan == .monthly
                                 ? "Monthly billing. Cancel anytime."
                                 : "Yearly billing. Best value.")
                            .font(.footnote)
                            .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.top, 6)

                        // Terms
                        Button {
                            agree.toggle()
                        } label: {
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: agree ? "checkmark.square.fill" : "square")
                                    .foregroundColor(.white)

                                Text("I agree to the Terms & Privacy Policy")
                                    .font(.footnote)
                                    .foregroundColor(.white.opacity(0.9))

                                Spacer()
                            }
                            .padding(.top, 4)
                        }
                        .buttonStyle(.plain)

                        // Submit
                        Button {
                            submitRegistration()
                        } label: {
                            HStack(spacing: 10) {
                                if isSubmitting {
                                    ProgressView().tint(.black)
                                } else {
                                    Image(systemName: "checkmark.seal.fill")
                                }

                                Text("Register & Pay")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(.white)
                            .foregroundColor(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 12)
                        }
                        .disabled(!isValid || isSubmitting)
                        .opacity(!isValid ? 0.7 : 1)

                        Text("After payment, your Clinic ID will be generated and emailed.")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.top, 2)
                    }
                    .padding(18)
                    .background(.white.opacity(0.16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(.white.opacity(0.22), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .padding(.horizontal, 18)

                    Color.clear.frame(height: 24)
                }
                .frame(maxWidth: .infinity, alignment: .top)
                .padding(.bottom, 80)
            }
            .scrollDismissesKeyboard(.interactively)
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .navigationTitle("Register Clinic")
        .alert("CaseCraft", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMsg)
        }
    }

    // MARK: - Validation (minimal)
    private var isValid: Bool {
        !clinicName.trimmed.isEmpty &&
        !ownerName.trimmed.isEmpty &&
        phone.trimmed.count >= 10 &&
        email.trimmed.contains("@") &&
        agree
    }

    private func submitRegistration() {
        guard isValid else { return }
        isSubmitting = true

        // TODO:
        // 1) POST clinicName, ownerName, phone, email, selectedPlan to PHP
        // 2) Create payment order (Razorpay/Juspay)
        // 3) Open payment sheet
        // 4) Verify payment -> generate Clinic ID -> email

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isSubmitting = false
            alertMsg = "Details submitted. Next step: Payment gateway integration."
            showAlert = true
        }
    }

    // MARK: - Field UI
    private func glassField(
        icon: String,
        placeholder: String,
        text: Binding<String>,
        keyboard: UIKeyboardType = .default,
        autocap: TextInputAutocapitalization = .words
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.white.opacity(0.9))

            TextField(placeholder, text: text)
                .keyboardType(keyboard)
                .textInputAutocapitalization(autocap)
                .autocorrectionDisabled(true)
                .foregroundColor(.white)
        }
        .padding()
        .background(.white.opacity(0.14))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(.white.opacity(0.22), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

extension String {
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
}

#Preview {
    NavigationStack { ClinicRegistrationView() }
}
