import SwiftUI

@main
struct SpontaneoApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                HomeView()
                    .tabItem{
                        Label("", systemImage: "house.fill")
                    }
                
                RewardsView()
                    .tabItem{
                        Label("", systemImage: "gift.fill")
                    }
                
                ProfileView(user: User.sampleUser)
                    .tabItem{
                        Label("", systemImage: "person.fill")
                    }
                
                ProfileView(user: User.sampleUser)
                    .tabItem{
                        Label("", systemImage: "person.fill")
                    }
            }
        }
    }
}
