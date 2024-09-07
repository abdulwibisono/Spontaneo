import SwiftUI
import UIKit
import SafariServices

struct HeaderView: View {

    @State private var showSearchResults = false
    
    var body: some View {
        HStack {
            Spacer()
            
            NavigationLink(destination: HomeView()){
                VStack {
                    Image(systemName: "gift.fill")
                    Text("Home")
                }
            }
            
            Spacer()
            
            NavigationLink(destination: RewardsView()){
                VStack {
                    Image(systemName: "gift.fill")
                    Text("Rewards")
                }
            }
            
            Spacer()
            
            VStack {
                Image(systemName: "gift.fill")
                Text("Activity")
            }
            
            Spacer()
            
            NavigationLink(destination: ProfileView(user: User.sampleUser)) {
                VStack {
                    Image(systemName: "gift.fill")
                    Text("Profile")
                }
            }
            
            Spacer()
        }
        .background(.blue)
    }
}

#Preview {
    HeaderView()
}
