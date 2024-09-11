import SwiftUI

struct AppTabBarView: View {
    @State private var tabSelection: TabBarItem = .home
    
    var body: some View {
        CustomTabBarContainerView(selection: $tabSelection) {
            HomeView()
                .tabBarItem(tab: .home, selection: $tabSelection)
            
            ActivityView()
                .tabBarItem(tab: .activities, selection: $tabSelection)
            
            RewardsView()
                .tabBarItem(tab: .rewards, selection: $tabSelection)

            ProfileView(user: User.sampleUser)
                .tabBarItem(tab: .profile, selection: $tabSelection)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

struct AppTabBarView_Previews: PreviewProvider {
    static var previews: some View {
        AppTabBarView()
    }
}
