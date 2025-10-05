import SwiftUI

@main
struct MLStudyAppApp: App {
    @StateObject private var gamificationService = GamificationService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gamificationService)
        }
    }
}
