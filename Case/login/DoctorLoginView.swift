import SwiftUI

struct DoctorLoginView: View {

    @EnvironmentObject private var appState: AppState
    @State private var path = NavigationPath()

    @State private var doctorId = ""
    @State private var password = ""
    @State private var showPassword = false

    @State private var isLoggingIn = false
    @State private var showAlert = false
    @State private var alertMsg = ""

    var body: some View {

        NavigationStack(path: $path) {

            ZStack {

                backgroundLayer
                blobsLayer

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {

                        Spacer(minLength: 28)

                        headerSection

                        formCard

                        Spacer(minLength: 30)
                    }
                }
            }
            // ✅ REGISTER BOTH DESTINATIONS HERE
            .navigationDestination(for: AuthRoute.self) { route in
                switch route {

                case .forgotPassword:
                    ForgotPasswordView(path: $path)
                        .environmentObject(appState)

                case .resetPassword(let email):
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
    }

    // MARK: Background

    private var backgroundLayer: some View {
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
    }

    private var blobsLayer: some View {
        ZStack {
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
        }
    }

    // MARK: Header

    private var headerSection: some View {
        VStack(spacing: 8) {

            ZStack {
                Circle()
                    .fill(.white.opacity(0.18))
                    .frame(width: 90, height: 90)

                Image(systemName: "stethoscope")
                    .font(.system(size: 38, weight: .semibold))
                    .foregroundColor(.white)
            }

            Text("Doctor Login")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text("Sign in using your Doctor ID")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.85))
        }
    }

    // MARK: Form Card

    private var formCard: some View {

        VStack(spacing: 16) {

            doctorIdField
            passwordField
            loginButton
            forgotPasswordButton

            Text("Your clinic will provide your Doctor ID and password.")
                .font(.footnote)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding(18)
        .background(.white.opacity(0.16))
        .overlay(cardBorder)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .padding(.horizontal, 18)
    }

    // MARK: Fields

    private var doctorIdField: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.text.rectangle")
                .foregroundColor(.white.opacity(0.9))

            TextField("Doctor ID", text: $doctorId)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .foregroundColor(.white)
        }
        .modifier(GlassInputStyle())
    }

    private var passwordField: some View {
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
        .modifier(GlassInputStyle())
    }

    // MARK: Forgot Password

    private var forgotPasswordButton: some View {
        Button {
            path.append(AuthRoute.forgotPassword)
        } label: {
            Text("Forgot Password?")
                .font(.footnote.weight(.semibold))
                .foregroundColor(.white.opacity(0.95))
        }
        .padding(.top, 4)
    }

    // MARK: Login Button

    private var loginButton: some View {
        Button(action: login) {

            HStack(spacing: 10) {
                if isLoggingIn { ProgressView().tint(.black) }
                else { Image(systemName: "arrow.right.circle.fill") }

                Text(isLoggingIn ? "Logging in..." : "Login")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
        }
        .background(Color.white)
        .foregroundColor(.black)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.18), radius: 18, x: 0, y: 10)
        .disabled(!canLogin || isLoggingIn)
        .opacity(!canLogin ? 0.75 : 1.0)
    }

    private var cardBorder: some View {
        RoundedRectangle(cornerRadius: 24)
            .stroke(.white.opacity(0.22), lineWidth: 1)
    }

    // MARK: Logic

    private var canLogin: Bool {
        !doctorId.trimmingCharacters(in: .whitespaces).isEmpty &&
        !password.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func login() {
        guard canLogin else { return }

        isLoggingIn = true
        let id = doctorId.trimmingCharacters(in: .whitespaces)
        let pass = password.trimmingCharacters(in: .whitespaces)

        Task {
            let success = await AuthAPI.shared.login(doctorId: id, password: pass)
            await MainActor.run {
                isLoggingIn = false
                if success {
                    appState.screen = .doctorDashboard
                } else {
                    alertMsg = "Invalid Doctor ID or Password"
                    showAlert = true
                }
            }
        }
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
