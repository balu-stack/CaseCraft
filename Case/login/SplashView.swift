import SwiftUI

struct SplashView: View {

    @EnvironmentObject private var appState: AppState

    @State private var animate = false

    var body: some View {
        ZStack {

            // MARK: - Dental Clinical Background
            LinearGradient(
                colors: [
                    Color.white,
                    Color(red: 230/255, green: 245/255, blue: 250/255),
                    Color(red: 200/255, green: 230/255, blue: 255/255)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Soft medical glow
            Circle()
                .fill(Color.blue.opacity(0.08))
                .frame(width: 350, height: 350)
                .blur(radius: 80)
                .offset(x: -150, y: -250)

            Circle()
                .fill(Color.cyan.opacity(0.06))
                .frame(width: 400, height: 400)
                .blur(radius: 90)
                .offset(x: 180, y: 300)

            VStack(spacing: 18) {

                Spacer()

                // MARK: - Implant Inspired Logo Animation
                ZStack {

                    // Titanium Ring Effect
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.blue.opacity(0.3), .cyan.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 4
                        )
                        .frame(width: 140, height: 140)
                        .rotationEffect(.degrees(animate ? 360 : 0))
                        .animation(.linear(duration: 5).repeatForever(autoreverses: false), value: animate)

                    // Glass background
                    Circle()
                        .fill(.white)
                        .frame(width: 110, height: 110)
                        .shadow(color: .blue.opacity(0.15), radius: 20, x: 0, y: 10)

                    Image(systemName: "cross.case.fill")
                        .font(.system(size: 45, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .cyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(animate ? 1.05 : 0.9)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: animate)
                }

                // App Name
                Text("CaseCraft")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(.blue.opacity(0.85))
                    .opacity(animate ? 1 : 0)
                    .animation(.easeIn(duration: 0.6), value: animate)

                Text("AI-Enabled Smart Case Documentation")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                Spacer()

                Text("Prosthodontics • Implantology • AI")
                    .font(.caption)
                    .foregroundColor(.gray.opacity(0.8))
                    .padding(.bottom, 30)
            }
        }
        .onAppear {

            // ✅ start animation
            animate = true

            // ✅ navigate after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                appState.screen = .landing     // or .doctorLogin
            }
        }
    }
}

#Preview {
    SplashView()
        .environmentObject(AppState())
}
