import SwiftUI

@main
struct SpontaneoApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                HomeView()
                ProfileView(user: User.sampleUser)
            }
        }
    }
}
