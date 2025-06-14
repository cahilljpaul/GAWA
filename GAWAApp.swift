import SwiftUI
import FirebaseCore
import FirebaseAuth

@main
struct GAAApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            if Auth.auth().currentUser == nil {
                LoginView()
            } else {
                MainTabView()
            }
        }
    }
}
