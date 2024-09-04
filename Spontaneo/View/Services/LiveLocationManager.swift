import UIKit
import MapKit
import CoreLocation

class LiveLocationManager: UIViewController {
    
    @IBOutlet var mapView: MapView!
    
    let liveLocationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        liveLocationManager.requestWhenInUseAuthorization()
        liveLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        liveLocationManager.distanceFilter = kCLDistanceFilterNone
        liveLocationManager.startUpdatingLocation()
        
        
    }
}
