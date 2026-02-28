import SwiftUI

struct ClinicLoginView: View {

    @State private var clinicId = "C-baluclinic45"
    @State private var password = "9087"
    @State private var showPassword = false

    @State private var otp = "9012"
    @State private var otpSent = false
    @State private var isSendingOTP = false
    @State private var isVerifying = false

    @State private var message: String? = nil
    @State private var showAlert = false

    // ✅ Use AppState navigation (root switch)
    @EnvironmentObject private var appState: AppState

    // Resend timer
    @State private var resendSeconds = 0
    private let resendCooldown = 60
    @State private var timer: Timer? = nil

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

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {

                    Spacer(minLength: 24)

                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(.white.opacity(0.18))
                                .frame(width: 90, height: 90)

                            Image(systemName: "building.2")
                                .font(.system(size: 36, weight: .semibold))
                                .foregroundColor(.white)
                        }

                        Text("Clinic Login")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        Text("Login with Clinic ID, password and OTP")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.85))
                    }

                    VStack(spacing: 16) {

                        // Clinic ID
                        HStack(spacing: 12) {
                            Image(systemName: "number")
                                .foregroundColor(.white.opacity(0.9))

                            TextField("Clinic ID (ex: C-2048)", text: $clinicId)
                                .textInputAutocapitalization(.never)
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

                        // Password
                        HStack(spacing: 12) {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.white.opacity(0.9))

                            Group {
                                if showPassword {
                                    TextField("Password", text: $password)
                                        .textInputAutocapitalization(.never)
                                } else {
                                    SecureField("Password", text: $password)
                                }
                            }
                            .foregroundColor(.white)

                            Button { showPassword.toggle() } label: {
                                Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                    .foregroundColor(.white.opacity(0.85))
                            }
                        }
                        .padding()
                        .background(.white.opacity(0.14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(.white.opacity(0.22), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                        // Send OTP
                        Button { sendOTP() } label: {
                            HStack(spacing: 10) {
                                if isSendingOTP {
                                    ProgressView().tint(.black)
                                } else {
                                    Image(systemName: "envelope.badge")
                                }

                                Text(otpSent ? "Resend OTP to Email" : "Send OTP to Email")
                                    .fontWeight(.semibold)

                                Spacer()

                                if resendSeconds > 0 {
                                    Text("\(resendSeconds)s")
                                        .font(.footnote)
                                        .foregroundColor(.black.opacity(0.6))
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(.white)
                            .foregroundColor(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(color: .black.opacity(0.12), radius: 14, x: 0, y: 8)
                        }
                        .disabled(!canSendOTP || isSendingOTP || resendSeconds > 0)
                        .opacity((!canSendOTP || resendSeconds > 0) ? 0.75 : 1)

                        if otpSent {
                            HStack(spacing: 12) {
                                Image(systemName: "key.fill")
                                    .foregroundColor(.white.opacity(0.9))

                                TextField("Enter OTP (sent to email)", text: $otp)
                                    .keyboardType(.numberPad)
                                    .textContentType(.oneTimeCode)
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .background(.white.opacity(0.14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(.white.opacity(0.22), lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        }

                        // Verify & Login
                        Button { verifyAndLogin() } label: {
                            HStack(spacing: 10) {
                                if isVerifying {
                                    ProgressView().tint(.black)
                                } else {
                                    Image(systemName: "checkmark.seal.fill")
                                }
                                Text("Verify OTP & Login")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(.white)
                            .foregroundColor(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(color: .black.opacity(0.18), radius: 18, x: 0, y: 10)
                        }
                        .disabled(!canVerify || isVerifying)
                        .opacity(!canVerify ? 0.75 : 1)

                        Text("OTP will be sent to the email linked with your Clinic ID.")
                            .font(.footnote)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.top, 4)
                    }
                    .padding(18)
                    .background(.white.opacity(0.16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(.white.opacity(0.22), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .padding(.horizontal, 18)

                    Spacer(minLength: 28)
                }
                .frame(maxWidth: .infinity, alignment: .top)
                .padding(.bottom, 40)
            }
            .scrollDismissesKeyboard(.interactively)
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .alert("CaseCraft", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(message ?? "")
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }

    // MARK: - Validation flags
    private var canSendOTP: Bool {
        !clinicId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var canVerify: Bool {
        otpSent && canSendOTP && !otp.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Actions
    private func sendOTP() {
        guard canSendOTP else { return }
        isSendingOTP = true
        message = nil

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isSendingOTP = false
            otpSent = true
            otp = ""
            showMsg("OTP sent to your registered email.")
            startResendTimer()
        }
    }

    private func verifyAndLogin() {
        guard canVerify else { return }
        isVerifying = true
        message = nil

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isVerifying = false

            // ✅ switch root screen
            appState.screen = .clinicDashboard
        }
    }

    private func showMsg(_ text: String) {
        message = text
        showAlert = true
    }

    private func startResendTimer() {
        resendSeconds = resendCooldown
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if resendSeconds > 0 {
                resendSeconds -= 1
            } else {
                timer?.invalidate()
                timer = nil
            }
        }
    }
}
