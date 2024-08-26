import SwiftUI

struct Home: View {
    var body: some View {
        
        HeaderView()
        
        VStack {
            HStack {
                Text("SPONTANEO")
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
            }
        }
        .padding()
    }
}

#Preview {
    Home()
}
