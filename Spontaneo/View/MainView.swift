import SwiftUI

struct MainView: View {
    var body: some View {
        NavigationView {
            VStack {
                Home()
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    MainView()
}
