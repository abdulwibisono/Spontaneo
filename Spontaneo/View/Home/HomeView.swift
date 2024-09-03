import SwiftUI

struct HomeView: View {
    
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        VStack {
            HeaderView()
            
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
                }
            } else {
                Text("Location access denied")
            }
            
            // Pass the location description as the address to MapView
            MapView(address: locationManager.locationDescription)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
