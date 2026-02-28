import SwiftUI

@main
struct CaseApp: App {

    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            SplashView()
                .environmentObject(appState)
        }
    }
}
