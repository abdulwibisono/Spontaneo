import SwiftUI

struct HomeView: View {
    
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        
        HeaderView()
        
        VStack {
            if locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways {
                VStack {
                    HStack {
                        Image(systemName: "mappin.circle.fill")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundColor(.red)
                            .padding(.leading)
                        
                        Text(locationManager.locationDescription)
                            .fontWeight(.medium)
                        Spacer()
                    }
                    
                    Divider()
                        .frame(width: 350)
                        .frame(height: 2)
                    
                }
            } else {
                Text("Location access denied")
            }
        }
        
        MapView()
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
