import SwiftUI

@main
struct SpontaneoApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                RewardsView()
                    .tabItem {
                        Label("Rewards", systemImage: "gift")
                    }
                ProfileView(user: User.sampleUser)
                    .tabItem {
                        Label("Profile", systemImage: "person")
                    }
            }
        }
    }
}
