import SwiftUI

struct ResetPasswordView: View {

    let email: String
    @Environment(\.dismiss) private var dismiss

    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showNew = false
    @State private var showConfirm = false

    @State private var isSaving = false
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

            VStack(spacing: 16) {
                Text("Create New Password")
                    .font(.title.bold())
                    .foregroundColor(.white)

                Text("For: \(email)")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.85))

                VStack(spacing: 12) {

                    passwordRow(
                        title: "New Password",
                        text: $newPassword,
                        show: $showNew
                    )

                    passwordRow(
                        title: "Confirm Password",
                        text: $confirmPassword,
                        show: $showConfirm
                    )

                    Button {
                        saveNewPassword()
                    } label: {
                        HStack(spacing: 10) {
                            if isSaving { ProgressView().tint(.black) }
                            Text(isSaving ? "Updating..." : "Update Password")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                    }
                    .background(.white)
                    .foregroundColor(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .disabled(!canSave || isSaving)
                    .opacity(!canSave ? 0.75 : 1.0)

                    Text("Password must be at least 6 characters.")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.8))
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
            }
            .padding(.top, 30)
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("CaseCraft", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: { Text(alertMsg) }
    }

    private var canSave: Bool {
        let a = newPassword.trimmingCharacters(in: .whitespacesAndNewlines)
        let b = confirmPassword.trimmingCharacters(in: .whitespacesAndNewlines)
        return a.count >= 6 && a == b
    }

    private func saveNewPassword() {
        guard canSave else { return }
        isSaving = true

        // TODO: Call backend API to update password by email.
        // For now demo success:
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            isSaving = false
            alertMsg = "Password updated successfully."
            showAlert = true

            // Go back to Login after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                // This dismisses one screen; if needed, user taps back twice.
                // Better approach: pop to root using NavigationStack path (can do if you want).
                dismiss()
            }
        }
    }

    @ViewBuilder
    private func passwordRow(title: String, text: Binding<String>, show: Binding<Bool>) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "lock.fill")
                .foregroundColor(.white.opacity(0.9))

            Group {
                if show.wrappedValue {
                    TextField(title, text: text)
                        .textInputAutocapitalization(.never)
                        .foregroundColor(.white)
                } else {
                    SecureField(title, text: text)
                        .foregroundColor(.white)
                }
            }

            Button { show.wrappedValue.toggle() } label: {
                Image(systemName: show.wrappedValue ? "eye.slash.fill" : "eye.fill")
                    .foregroundColor(.white.opacity(0.85))
            }
        }
        .modifier(GlassInputStyle())
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