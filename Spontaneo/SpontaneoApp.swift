import SwiftUI
import FirebaseCore
import FirebaseFirestore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        let db = Firestore.firestore()
        return true
    }
}

@main
struct SpontaneoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authService = AuthenticationService()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                if authService.user != nil {
                    AppTabBarView()
                } else {
                    LoginView(authService: authService)
                }
            }
            .environmentObject(authService)
        }
    }
}
