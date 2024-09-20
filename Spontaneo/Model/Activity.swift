import Foundation
import MapKit

struct Activity: Identifiable, Hashable {
    let id: UUID
    let title: String
    let category: String
    let date: Date
    let location: Location
    let currentParticipants: Int
    let maxParticipants: Int
    let host: Host
    let description: String
    let tags: [String]
    var receiveUpdates: Bool
    let updates: [String]
    let relatedActivities: [Activity]

    struct Location: Hashable {
        let name: String
        let coordinate: CLLocationCoordinate2D
        
        static func == (lhs: Location, rhs: Location) -> Bool {
            return lhs.name == rhs.name &&
                   lhs.coordinate.latitude == rhs.coordinate.latitude &&
                   lhs.coordinate.longitude == rhs.coordinate.longitude
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(name)
            hasher.combine(coordinate.latitude)
            hasher.combine(coordinate.longitude)
        }
    }

    static let sampleActivities = [
        Activity(
            id: UUID(),
            title: "Morning Coffee Meetup",
            category: "Coffee",
            date: Date().addingTimeInterval(3600),
            location: Location(name: "The Coffee Club - Queen Street Mall", coordinate: CLLocationCoordinate2D(latitude: -27.4697, longitude: 153.0251)),
            currentParticipants: 5,
            maxParticipants: 10,
            host: Host(name: "John Doe", profilePicture: URL(string: "https://example.com/john.jpg"), rating: 4.5),
            description: "Start your day with a friendly coffee meetup. Great opportunity to network and make new friends!",
            tags: ["CoffeeLovers", "Networking", "MorningPerson"],
            receiveUpdates: true,
            updates: ["New participant joined!", "Reminder: Meeting tomorrow at 8 AM"],
            relatedActivities: []
        ),
        Activity(
            id: UUID(),
            title: "Group Study Session: Data Structures",
            category: "Study",
            date: Date().addingTimeInterval(7200),
            location: Location(name: "State Library of Queensland", coordinate: CLLocationCoordinate2D(latitude: -27.4709, longitude: 153.0235)),
            currentParticipants: 3,
            maxParticipants: 8,
            host: Host(name: "Emma Watson", profilePicture: URL(string: "https://example.com/emma.jpg"), rating: 4.8),
            description: "Join our study group focusing on Data Structures and Algorithms. All levels welcome!",
            tags: ["ComputerScience", "StudyGroup", "DataStructures"],
            receiveUpdates: true,
            updates: ["Bring your laptops!", "We'll be covering Binary Trees today"],
            relatedActivities: []
        ),
        Activity(
            id: UUID(),
            title: "Beach Volleyball Tournament",
            category: "Sports",
            date: Date().addingTimeInterval(86400),
            location: Location(name: "Streets Beach, South Bank", coordinate: CLLocationCoordinate2D(latitude: -27.4774, longitude: 153.0255)),
            currentParticipants: 12,
            maxParticipants: 24,
            host: Host(name: "Mike Johnson", profilePicture: URL(string: "https://example.com/mike.jpg"), rating: 4.7),
            description: "Join our friendly beach volleyball tournament. All skill levels welcome!",
            tags: ["BeachVolleyball", "SummerFun", "TeamSport"],
            receiveUpdates: true,
            updates: ["Bring sunscreen and water!", "Tournament starts at 10 AM sharp"],
            relatedActivities: []
        ),
        Activity(
            id: UUID(),
            title: "Vegan Food Festival",
            category: "Food",
            date: Date().addingTimeInterval(172800),
            location: Location(name: "Brisbane City Botanic Gardens", coordinate: CLLocationCoordinate2D(latitude: -27.4747, longitude: 153.0302)),
            currentParticipants: 50,
            maxParticipants: 200,
            host: Host(name: "Green Eats Brisbane", profilePicture: URL(string: "https://example.com/greeneats.jpg"), rating: 4.9),
            description: "Explore a wide variety of vegan cuisines from local restaurants and food trucks!",
            tags: ["VeganFood", "FoodFestival", "HealthyEating"],
            receiveUpdates: true,
            updates: ["New food truck added: Vegan Delights", "Live music performance at 2 PM"],
            relatedActivities: []
        ),
        Activity(
            id: UUID(),
            title: "Brisbane Night Photography Walk",
            category: "Explore",
            date: Date().addingTimeInterval(259200),
            location: Location(name: "Story Bridge", coordinate: CLLocationCoordinate2D(latitude: -27.4648, longitude: 153.0341)),
            currentParticipants: 8,
            maxParticipants: 15,
            host: Host(name: "Sarah Lee", profilePicture: URL(string: "https://example.com/sarah.jpg"), rating: 4.6),
            description: "Capture the beauty of Brisbane at night. Bring your camera and tripod!",
            tags: ["Photography", "NightLife", "CityExploration"],
            receiveUpdates: true,
            updates: ["Meeting point changed to Story Bridge pedestrian walkway", "Workshop on long exposure techniques included"],
            relatedActivities: []
        ),
        Activity(
            id: UUID(),
            title: "Riverside Yoga Session",
            category: "Sports",
            date: Date().addingTimeInterval(14400),
            location: Location(name: "New Farm Park", coordinate: CLLocationCoordinate2D(latitude: -27.4712, longitude: 153.0530)),
            currentParticipants: 10,
            maxParticipants: 20,
            host: Host(name: "Yoga With Emily", profilePicture: URL(string: "https://example.com/emily.jpg"), rating: 4.9),
            description: "Start your day with a rejuvenating yoga session by the river. All levels welcome!",
            tags: ["Yoga", "Wellness", "MorningRoutine"],
            receiveUpdates: true,
            updates: ["Bring your own mat", "Session starts at 6:30 AM"],
            relatedActivities: []
        ),
        Activity(
            id: UUID(),
            title: "Brisbane History Walking Tour",
            category: "Explore",
            date: Date().addingTimeInterval(345600),
            location: Location(name: "King George Square", coordinate: CLLocationCoordinate2D(latitude: -27.4688, longitude: 153.0234)),
            currentParticipants: 7,
            maxParticipants: 15,
            host: Host(name: "Brisbane Heritage Tours", profilePicture: URL(string: "https://example.com/bht.jpg"), rating: 4.8),
            description: "Discover the rich history of Brisbane on this guided walking tour through the city's historic sites.",
            tags: ["History", "Walking", "CityTour"],
            receiveUpdates: true,
            updates: ["Tour duration: approximately 2 hours", "Comfortable walking shoes recommended"],
            relatedActivities: []
        )
    ]

    static var sampleActivity: Activity {
        return sampleActivities[0]
    }
}

struct Host: Hashable {
    let name: String
    let profilePicture: URL?
    let rating: Double
}
