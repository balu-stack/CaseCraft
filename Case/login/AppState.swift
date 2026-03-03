import SwiftUI

final class AppState: ObservableObject {

    enum Screen {
        case splash
        case landing
        case doctorLogin
        case doctorDashboard
        case clinicLogin
        case clinicDashboard
    }

    @Published var screen: Screen = .splash
}
