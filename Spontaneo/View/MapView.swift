import SwiftUI
import MapKit

struct MapView: View {
    var address: String
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 34.011286, longitude: -116.166868),
        span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
    )
    
    @State private var location: LocationAnnotation?

    var body: some View {
        Map(coordinateRegion: $region, annotationItems: [location].compactMap { $0 }) { annotation in
            MapPin(coordinate: annotation.coordinate, tint: .red)
        }
        .onAppear {
            geocodeAddress(address)
        }
        .ignoresSafeArea()
    }

    func geocodeAddress(_ address: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            if let error = error {
                print(error)
                return
            }
            if let location = placemarks?.first?.location {
                    self.location = LocationAnnotation(coordinate: location.coordinate)
                    self.region.center = location.coordinate
                }
            }
        }
    }


struct LocationAnnotation: Identifiable {
    let id = UUID()
    var coordinate: CLLocationCoordinate2D
}
