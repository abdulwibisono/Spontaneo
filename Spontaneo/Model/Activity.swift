import Foundation
import FirebaseFirestore
import MapKit

struct Activity: Identifiable, Codable {
    @DocumentID var id: String?
    let title: String
    let category: String
    let date: Date
    let location: Location
    let currentParticipants: Int
    let maxParticipants: Int
    let hostId: String
    let hostName: String
    let description: String
    let tags: [String]
    var receiveUpdates: Bool
    let updates: [String]
    let rating: Double
    
    struct Location: Codable, Hashable {
        let name: String
        let latitude: Double
        let longitude: Double
        
        var coordinate: CLLocationCoordinate2D {
            CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }
}
