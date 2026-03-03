import SwiftUI

struct ForgotPasswordView: View {

    @EnvironmentObject private var appState: AppState
    @Binding var path: NavigationPath

    @State private var email = ""
    @State private var otp = ""

    @State private var otpSent = false
    @State private var isLoading = false

    @State private var showAlert = false
    @State private var alertMsg = ""

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

            VStack(spacing: 18) {

                Text("Forgot Password")
                    .font(.title.bold())
                    .foregroundColor(.white)

                HStack {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(.white)

                    TextField("Enter your email", text: $email)
                        .foregroundColor(.white)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .keyboardType(.emailAddress)
                }
                .modifier(GlassInputStyle())

                if otpSent {
                    VStack(spacing: 10) {

                        HStack {
                            Image(systemName: "number.circle.fill")
                                .foregroundColor(.white)

                            TextField("Enter OTP", text: $otp)
                                .keyboardType(.numberPad)
                                .foregroundColor(.white)
                        }
                        .modifier(GlassInputStyle())

                        Button("Resend OTP") { resendOtp() }
                            .font(.footnote.weight(.semibold))
                            .foregroundColor(.white.opacity(0.95))
                            .disabled(isLoading)
                            .opacity(isLoading ? 0.7 : 1.0)
                    }
                }

                Button {
                    if otpSent { verifyOtp() }
                    else { sendOtp() }
                } label: {
                    HStack(spacing: 10) {
                        if isLoading { ProgressView().tint(.black) }
                        Text(isLoading ? "Please wait..." : (otpSent ? "Verify OTP" : "Send OTP"))
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                }
                .background(.white)
                .foregroundColor(.black)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .disabled(isLoading)
            }
            .padding(18)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: AuthRoute.self) { route in
            if case .resetPassword(let email) = route {
                ResetPasswordView(email: email, path: $path)
                    .environmentObject(appState)
            }
        }
        .alert("CaseCraft", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMsg)
        }
    }

    private func sendOtp() {

        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            alertMsg = "Enter email"
            showAlert = true
            return
        }

        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            isLoading = false
            otpSent = true
            otp = ""
            alertMsg = "OTP sent successfully"
            showAlert = true
        }
    }

    private func resendOtp() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            isLoading = false
            otp = ""
            alertMsg = "OTP resent successfully"
            showAlert = true
        }
    }

    private func verifyOtp() {

        let code = otp.trimmingCharacters(in: .whitespacesAndNewlines)

        guard code == "1234" else {
            alertMsg = "Invalid OTP"
            showAlert = true
            return
        }

        path.append(AuthRoute.resetPassword(email: email))
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
            .clipShape(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
    }
}
