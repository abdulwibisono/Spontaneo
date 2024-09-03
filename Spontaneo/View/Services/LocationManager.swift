//import CoreLocation
//import Network
//import UIKit
//import MapKit
//
//class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
//    private let locationManager = CLLocationManager()
//    private let geocoder = CLGeocoder()
//    private var networkMonitor: NWPathMonitor?
//    
//    @Published var locationDescription: String = "Initializing..."
//    @Published var lastLocation: CLLocation?
//    @Published var authorizationStatus: CLAuthorizationStatus?
//    @Published var isNetworkAvailable: Bool = true
//    
//    override init() {
//        super.init()
//        setupLocationManager()
//        setupNetworkMonitoring()
//    }
//    
//    private func setupLocationManager() {
//        locationManager.delegate = self
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        locationManager.distanceFilter = 10
//        checkLocationAuthorization()
//    }
//    
//    private func setupNetworkMonitoring() {
//            networkMonitor = NWPathMonitor()
//            networkMonitor?.pathUpdateHandler = { [weak self] path in
//                DispatchQueue.main.async {
//                    self?.isNetworkAvailable = path.status == .satisfied
//                    if !self!.isNetworkAvailable {
//                        self?.locationDescription = "No internet connection. Geocoding may fail."
//                    }
//                }
//            }
//            let queue = DispatchQueue(label: "NetworkMonitor")
//            networkMonitor?.start(queue: queue)
//        }
//        
//        private func checkLocationAuthorization() {
//            switch locationManager.authorizationStatus {
//            case .authorizedWhenInUse, .authorizedAlways:
//                locationManager.startUpdatingLocation()
//                requestLocation()
//            case .denied, .restricted:
//                locationDescription = "Location access denied. Please enable in Settings."
//            case .notDetermined:
//                locationManager.requestWhenInUseAuthorization()
//            @unknown default:
//                locationDescription = "Unknown authorization status"
//            }
//        }
//    
//    func requestLocation() {
//        if CLLocationManager.locationServicesEnabled() {
//            locationManager.requestLocation()
//            locationDescription = "Requesting location..."
//        } else {
//            locationDescription = "Location services are disabled. Please enable in Settings."
//        }
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let location = locations.last else { return }
//        lastLocation = location
//        locationDescription = "Lat: \(location.coordinate.latitude), Lon: \(location.coordinate.longitude)"
//        geocodeLocation(location)
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        print("Location Error: \(error.localizedDescription)")
//        if let clError = error as? CLError {
//            switch clError.code {
//            case .locationUnknown:
//                locationDescription = "Unable to determine location. Retrying..."
//                // Retry after a short delay
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
//                    self?.requestLocation()
//                }
//            case .denied:
//                locationDescription = "Location access denied. Please enable in Settings."
//            case .network:
//                locationDescription = "Network error. Please check your connection and try again."
//            default:
//                locationDescription = "Error determining location: \(clError.localizedDescription)"
//            }
//        } else {
//            locationDescription = "Unexpected error: \(error.localizedDescription)"
//        }
//    }
//    
//    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
//        authorizationStatus = manager.authorizationStatus
//        checkLocationAuthorization()
//    }
//    
//    private func geocodeLocation(_ location: CLLocation) {
//        guard isNetworkAvailable else {
//            locationDescription = "No internet connection. Unable to geocode location."
//            return
//        }
//        
//        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
//            if let placemark = placemarks?.first,
//               let city = placemark.locality,
//               let country = placemark.country {
//                self?.locationDescription = "You're in \(city), \(country)"
//            } else {
//                self?.locationDescription = "Location details not available"
//            }
//        }
//    }
//    
//    deinit {
//        networkMonitor?.cancel()
//    }
//}
