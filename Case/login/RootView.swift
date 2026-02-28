import SwiftUI

struct RootView: View {

    @EnvironmentObject var appState: AppState

    var body: some View {
        switch appState.screen {

        case .landing:
            CaseCraftLoginLandingView()

        case .doctorLogin:
            DoctorLoginView()

        case .doctorDashboard:
            DoctorDashboardRootView()

        case .clinicLogin:
            ClinicLoginView()

        case .clinicDashboard:
            ClinicDashboardRootView()
        }
    }
}
