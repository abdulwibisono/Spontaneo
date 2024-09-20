import Foundation
import MapKit

struct Activity: Identifiable, Hashable {
    let id: UUID
    let title: String
    let category: String
    let date: Date
    let location: CLLocation
    let currentParticipants: Int
    let maxParticipants: Int
    let host: Host
    let description: String
    let tags: [String]
    var receiveUpdates: Bool
    let updates: [String]
    let relatedActivities: [Activity]

    static let sampleActivity = Activity(
        id: UUID(),
        title: "Morning Coffee Meetup",
        category: "Coffee",
        date: Date().addingTimeInterval(3600),
        location: CLLocation(latitude: 37.7749, longitude: -122.4194),
        currentParticipants: 5,
        maxParticipants: 10,
        host: Host(name: "John Doe", profilePicture: URL(string: "https://example.com/profile.jpg"), rating: 4.5),
        description: "Join us for a morning coffee meetup at the local cafe. Meet new people and enjoy a great start to your day!",
        tags: ["CoffeeLovers", "MorningMeetup"],
        receiveUpdates: true,
        updates: ["Location changed to Main St Cafe", "New participant joined!"],
        relatedActivities: []
    )
}

struct Host: Hashable {
    let name: String
    let profilePicture: URL?
    let rating: Double
}
