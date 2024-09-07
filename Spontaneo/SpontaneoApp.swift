import SwiftUI

@main
struct SpontaneoApp: App {
    var body: some Scene {
        WindowGroup {
                HomeView()
                RewardsView()
                ProfileView(user: User.sampleUser)
            
        }
    }
}
