import SwiftUI

struct ForgotPasswordEmailView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var email = ""
    @State private var isSending = false
    @State private var showAlert = false
    @State private var alertMsg = ""

    // navigation
    @State private var goOtp = false

    var body: some View {
        ZStack {
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

            VStack(spacing: 16) {
                Text("Forgot Password")
                    .font(.title.bold())
                    .foregroundColor(.white)

                Text("Enter your registered email to receive OTP.")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.center)

                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(.white.opacity(0.9))

                        TextField("Email address", text: $email)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled(true)
                            .foregroundColor(.white)
                    }
                    .modifier(GlassInputStyle())

                    Button {
                        sendOtp()
                    } label: {
                        HStack(spacing: 10) {
                            if isSending { ProgressView().tint(.black) }
                            Text(isSending ? "Sending..." : "Send OTP")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                    }
                    .background(.white)
                    .foregroundColor(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .disabled(!isValidEmail(email) || isSending)
                    .opacity(!isValidEmail(email) ? 0.75 : 1.0)

                    Button("Back to Login") { dismiss() }
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.top, 6)
                }
                .padding(18)
                .background(.white.opacity(0.16))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(.white.opacity(0.22), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .padding(.horizontal, 18)

                NavigationLink(
                    destination: OTPVerifyView(email: email),
                    isActive: $goOtp
                ) { EmptyView() }
            }
            .padding(.top, 30)
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("CaseCraft", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: { Text(alertMsg) }
    }

    private func sendOtp() {
        guard isValidEmail(email) else { return }
        isSending = true

        // TODO: Call backend API to send OTP to email.
        // For now, simulate success:
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            isSending = false
            goOtp = true
        }
    }

    private func isValidEmail(_ s: String) -> Bool {
        let trimmed = s.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.contains("@") && trimmed.contains(".") && trimmed.count >= 6
    }
}

private struct GlassInputStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(.white.opacity(0.14))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(.white.opacity(0.22), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}