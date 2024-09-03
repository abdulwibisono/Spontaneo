import SwiftUI
import MapKit

struct MapView: View {
    
    @StateObject var viewModel = ContentViewModel()
    
    var body: some View {
        VStack {
            Map(coordinateRegion: viewModel.binding,showsUserLocation: true,userTrackingMode: .constant(.follow))
                .edgesIgnoringSafeArea(.all)
                .onAppear(perform: {
                    viewModel.checkIfLocationIsEnabled()
                })
            
        }
        
    }
}


final class ContentViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    var locationManager: CLLocationManager?

    @Published var mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 43.457105, longitude: -80.508361), span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))

    var binding: Binding<MKCoordinateRegion> {
        Binding {
            self.mapRegion
        } set: { newRegion in
            self.mapRegion = newRegion
        }
    }

    func checkIfLocationIsEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            locationManager!.delegate = self
        } else {
            print("Show an alert letting them know this is off")
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let previousAuthorizationStatus = manager.authorizationStatus
        manager.requestWhenInUseAuthorization()
        if manager.authorizationStatus != previousAuthorizationStatus {
            checkLocationAuthorization()
        }
    }

    private func checkLocationAuthorization() {
        guard let location = locationManager else {
            return
        }

        switch location.authorizationStatus {
        case .notDetermined:
            print("Location authorization is not determined.")
        case .restricted:
            print("Location is restricted.")
        case .denied:
            print("Location permission denied.")
        case .authorizedAlways, .authorizedWhenInUse:
            if let location = location.location {
                mapRegion = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
            }

        default:
            break
        }
    }
}
//    @StateObject private var locationManager = LocationManager()
//    @State private var region = MKCoordinateRegion(
//        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
//        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
//    )
//
//    var body: some View {
//        ZStack {
//            Map(coordinateRegion: $region, showsUserLocation: true)
//                .edgesIgnoringSafeArea(.all)
//            
//            VStack {
//                Spacer()
//                Text(locationManager.locationDescription)
//                    .padding()
//                    .background(Color.white.opacity(0.7))
//                    .cornerRadius(10)
//                    .padding()
//            }
//        }
//        .onChange(of: locationManager.lastLocation) { newLocation in
//            if let location = newLocation {
//                region = MKCoordinateRegion(
//                    center: location.coordinate,
//                    span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
//                )
//            }
//        }
//    }
//}
