import SwiftUI

struct DoctorLoginView: View {

    @State private var doctorId = ""
    @State private var password = ""
    @State private var showPassword = false

    @State private var isLoggingIn = false
    @State private var showAlert = false
    @State private var alertMsg = ""

    @EnvironmentObject private var appState: AppState

    var body: some View {
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
        .alert("CaseCraft", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMsg)
        }
    }

    // MARK: - Layers

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

    // MARK: - Sections

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
        .padding(.top, 8)
    }

    private var formCard: some View {
        VStack(spacing: 16) {
            doctorIdField
            passwordField
            loginButton

            Text("Your clinic will provide your Doctor ID and password.")
                .font(.footnote)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.top, 4)
        }
        .padding(18)
        .background(.white.opacity(0.16))
        .overlay(cardBorder)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .padding(.horizontal, 18)
    }

    // MARK: - Fields

    private var doctorIdField: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.text.rectangle")
                .foregroundColor(.white.opacity(0.9))

            TextField("Doctor ID (ex: D-1024)", text: $doctorId)
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

            passwordInput

            Button { showPassword.toggle() } label: {
                Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                    .foregroundColor(.white.opacity(0.85))
            }
        }
        .modifier(GlassInputStyle())
    }

    private var passwordInput: some View {
        Group {
            if showPassword {
                TextField("Password", text: $password)
                    .textInputAutocapitalization(.never)
            } else {
                SecureField("Password", text: $password)
            }
        }
        .foregroundColor(.white)
    }

    // MARK: - Button

    private var loginButton: some View {
        Button(action: login) {
            HStack(spacing: 10) {
                if isLoggingIn {
                    ProgressView().tint(.black)
                } else {
                    Image(systemName: "arrow.right.circle.fill")
                }

                Text(isLoggingIn ? "Logging in..." : "Login")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
        }
        .background(Color.white)
        .foregroundColor(.black)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.18), radius: 18, x: 0, y: 10)
        .disabled(!canLogin || isLoggingIn)
        .opacity(!canLogin ? 0.75 : 1.0)
    }

    private var cardBorder: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .stroke(.white.opacity(0.22), lineWidth: 1)
    }

    // MARK: - Logic

    private var canLogin: Bool {
        !doctorId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func login() {
        guard canLogin else { return }

        isLoggingIn = true

        let id = doctorId.trimmingCharacters(in: .whitespacesAndNewlines)
        let pw = password.trimmingCharacters(in: .whitespacesAndNewlines)

        Task {
            let success = await AuthAPI.shared.login(doctorId: id, password: pw)

            await MainActor.run {
                isLoggingIn = false

                if success {
                    appState.screen = .doctorDashboard
                } else {
                    alertMsg = "Invalid Doctor ID or Password."
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
