import SwiftUI

struct ClinicDashboardRootView: View {

    @State private var selectedTab: Tab = .home
    enum Tab: Hashable { case home, doctors, patients, cases, profile }

    var body: some View {
        NavigationStack {   // ✅ ONE stack for all tabs

            TabView(selection: $selectedTab) {

                ClinicDashboardView()
                    .tag(Tab.home)
                    .tabItem {
                        TabIcon(systemName: "house.fill", title: "Home",
                                isSelected: selectedTab == .home, glow: .cyan)
                    }

                ClinicDoctorsView()
                    .tag(Tab.doctors)
                    .tabItem {
                        TabIcon(systemName: "stethoscope", title: "Doctors",
                                isSelected: selectedTab == .doctors, glow: .purple)
                    }

                ClinicPatientsView()
                    .tag(Tab.patients)
                    .tabItem {
                        TabIcon(systemName: "person.3.fill", title: "Patients",
                                isSelected: selectedTab == .patients, glow: .blue)
                    }

                ClinicCasesView()
                    .tag(Tab.cases)
                    .tabItem {
                        TabIcon(systemName: "doc.text.fill", title: "Cases",
                                isSelected: selectedTab == .cases, glow: .mint)
                    }

                ClinicProfileView()
                    .tag(Tab.profile)
                    .tabItem {
                        TabIcon(systemName: "person.crop.circle.fill", title: "Profile",
                                isSelected: selectedTab == .profile, glow: .orange)
                    }
            }
            .modifier(ClinicTabBarStyle())
        }
    }
}
