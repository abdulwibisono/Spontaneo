import SwiftUI

struct HomeView: View {
    
    var body: some View {
        HeaderView()
        
        MapView(address: "13 Railway Tce, Milton, QLD 4064")
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
