import SwiftUI

struct ClinicProfileView: View {

    @EnvironmentObject private var appState: AppState

    @State private var showLogoutAlert = false

    // demo values
    private let clinicName = "Balu Clinic"
    private let clinicId = "C-baluclinic45"
    private let email = "clinic@email.com"

    var body: some View {
        ZStack {
            CaseCraftBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {

                    ClinicGlassCard {
                        HStack(spacing: 12) {
                            Image(systemName: "building.2.crop.circle.fill")
                                .font(.system(size: 56))
                                .foregroundStyle(.white.opacity(0.9))

                            VStack(alignment: .leading, spacing: 4) {
                                Text(clinicName)
                                    .font(.title3.bold())
                                    .foregroundStyle(.white)
                                Text("Clinic ID: \(clinicId)")
                                    .font(.footnote)
                                    .foregroundStyle(.white.opacity(0.75))
                                Text(email)
                                    .font(.footnote)
                                    .foregroundStyle(.white.opacity(0.75))
                            }

                            Spacer()
                        }
                    }
                    .padding(.horizontal)

                    ClinicGlassCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Actions")
                                .font(.headline)
                                .foregroundStyle(.white)

                            Button(role: .destructive) {
                                showLogoutAlert = true
                            } label: {
                                HStack {
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                    Text("Logout")
                                        .fontWeight(.semibold)
                                    Spacer()
                                }
                                .foregroundStyle(.white)
                                .padding(12)
                                .background(.red.opacity(0.18))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                        }
                    }
                    .padding(.horizontal)

                    Spacer(minLength: 20)
                }
                .padding(.top, 14)
                .padding(.bottom, 26)
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)

        .alert("Logout", isPresented: $showLogoutAlert) {
            Button("Cancel", role: .cancel) {}

            Button("Logout", role: .destructive) {
                // ✅ Choose ONE:

                appState.screen = .landing       // ✅ best (no back issues)
                // appState.screen = .clinicLogin // ✅ if you want direct clinic login
            }

        } message: {
            Text("Are you sure you want to logout?")
        }
    }
}
