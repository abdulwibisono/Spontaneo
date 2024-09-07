import SwiftUI

struct NavBar:  View {
    var body: some View {
        HStack {
            Spacer()
            
            NavigationLink(destination: HomeView()){
                VStack{
                    Image(systemName: "house.fill")
                }
            }
            
            Spacer()
            
            NavigationLink(destination: RewardsView()){
                    Image(systemName: "gift.fill")
            }
            
            Spacer()
            
            NavigationLink(destination: ProfileView(user: User.sampleUser)){
                VStack{
                    Image(systemName: "person.fill")
                }
            }
            
            Spacer()
            
            NavigationLink(destination: HomeView()){
                VStack{
                    Image(systemName: "person.fill")
                }
            }
            
            Spacer()
        }
        .foregroundColor(.black)
        .background(.cyan)
        .padding()
        .padding(.top, 20)
        .padding(.bottom, 20)
    }
}

#Preview {
    NavBar()
}
