import SwiftUI

struct MainView: View {
    var body: some View {
        NavigationView {
            VStack {
                HomeView()
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    MainView()
}
