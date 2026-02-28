import SwiftUI

struct CaseCraftLoginLandingView: View {

    enum Role: String, CaseIterable {
        case doctor = "Doctor"
        case clinic = "Clinic"
    }

    @EnvironmentObject var appState: AppState
    @State private var selectedRole: Role = .doctor

    var body: some View {

        ZStack {

            // 🌈 UPDATED PREMIUM MEDICAL BACKGROUND
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

            // ✨ Soft glow for depth
            Circle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 280, height: 280)
                .blur(radius: 60)
                .offset(x: -120, y: -220)

            Circle()
                .fill(Color.cyan.opacity(0.12))
                .frame(width: 220, height: 220)
                .blur(radius: 70)
                .offset(x: 140, y: 260)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {

                    Spacer(minLength: 30)

                    // Logo + App Name
                    VStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(.white.opacity(0.18))
                                .frame(width: 96, height: 96)

                            Image(systemName: "doc.text.magnifyingglass")
                                .font(.system(size: 40, weight: .semibold))
                                .foregroundColor(.white)
                        }

                        Text("CaseCraft")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        Text("AI-Enabled Smart Case Documentation")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.85))
                    }
                    .padding(.top, 8)

                    // Glass Card
                    VStack(spacing: 18) {

                        // Role Picker (Doctor / Clinic)
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Choose Login Type")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.95))

                            HStack(spacing: 10) {
                                ForEach(Role.allCases, id: \.self) { role in
                                    RolePill(
                                        title: role.rawValue,
                                        isSelected: selectedRole == role
                                    ) {
                                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                            selectedRole = role
                                        }
                                    }
                                }
                            }
                        }

                        // ✅ Primary CTA using AppState (NO NavigationLink)
                        Button {
                            if selectedRole == .doctor {
                                appState.screen = .doctorLogin
                            } else {
                                appState.screen = .clinicLogin
                            }
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: selectedRole == .doctor ? "stethoscope" : "building.2")
                                Text(selectedRole == .doctor ? "Continue as Doctor" : "Continue as Clinic")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(.white)
                            .foregroundColor(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(color: .black.opacity(0.18), radius: 18, x: 0, y: 10)
                        }

                        // ✅ Registration: if you still want it, it should also be AppState-based
                        if selectedRole == .clinic {
                            Button {
                                // If you want a screen for registration, add it in AppState.Screen
                                // appState.screen = .clinicRegister
                            } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Register Your Clinic")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 13)
                                .background(.white.opacity(0.18))
                                .foregroundColor(.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(.white.opacity(0.35), lineWidth: 1)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            }
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        }

                        Divider().overlay(.white.opacity(0.25))

                        VStack(spacing: 6) {
                            Text(selectedRole == .doctor
                                 ? "Doctors get credentials from their clinic."
                                 : "Clinics can register and create doctor credentials.")
                            .font(.footnote)
                            .foregroundColor(.white.opacity(0.85))
                            .multilineTextAlignment(.center)

                            Text("Secure login • Privacy first")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.75))
                        }
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
            }
        }
    }
}
private struct RolePill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .foregroundColor(isSelected ? .black : .white)
                .background(isSelected ? .white : .white.opacity(0.14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(.white.opacity(isSelected ? 0 : 0.25), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}
