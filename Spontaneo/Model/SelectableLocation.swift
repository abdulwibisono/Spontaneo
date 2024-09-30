import SwiftUI
import CoreLocation

public struct SelectableLocation: Identifiable, Equatable {
    public let id = UUID()
    public let coordinate: CLLocationCoordinate2D
    public let name: String
    
    public init(coordinate: CLLocationCoordinate2D, name: String) {
        self.coordinate = coordinate
        self.name = name
    }
    
    public static func == (lhs: SelectableLocation, rhs: SelectableLocation) -> Bool {
        lhs.id == rhs.id
    }
}