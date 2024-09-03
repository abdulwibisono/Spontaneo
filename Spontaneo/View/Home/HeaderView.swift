import SwiftUI
import UIKit
import SafariServices

struct HeaderView: View {

    @State private var showSearchResults = false
    
    var body: some View {
        VStack {
            HStack {
                Text("**Spontaneo**")
                    .font(.system(size:30))
                    .frame(width: 200)
                    .padding(.leading, -5)
                
                Spacer()
                
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size:30))
                    .frame(width: 200)
                    .padding(.trailing, -40)
            }
        }
    }
}

#Preview {
    HeaderView()
}
