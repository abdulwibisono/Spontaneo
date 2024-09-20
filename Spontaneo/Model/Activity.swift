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
            title: "Afternoon Tea and Book Discussion",
            category: "Coffee",
            date: Date().addingTimeInterval(345600),
            location: Location(name: "Avid Reader Bookshop", coordinate: CLLocationCoordinate2D(latitude: -27.4818, longitude: 153.0120)),
            currentParticipants: 6,
            maxParticipants: 12,
            host: Host(name: "Olivia Green", profilePicture: URL(string: "https://example.com/olivia.jpg"), rating: 4.3),
            description: "Join us for a cozy afternoon tea and discussion of this month's book club selection.",
            tags: ["BookClub", "AfternoonTea", "Literature"],
            receiveUpdates: true,
            updates: ["Book for discussion: 'The Midnight Library' by Matt Haig"],
            relatedActivities: []
        ),
        Activity(
            id: UUID(),
            title: "Coding Workshop: Mobile App Development",
            category: "Study",
            date: Date().addingTimeInterval(432000),
            location: Location(name: "River City Labs", coordinate: CLLocationCoordinate2D(latitude: -27.4678, longitude: 153.0281)),
            currentParticipants: 15,
            maxParticipants: 30,
            host: Host(name: "Alex Chen", profilePicture: URL(string: "https://example.com/alex.jpg"), rating: 4.9),
            description: "Learn the basics of mobile app development in this hands-on workshop.",
            tags: ["Coding", "MobileApps", "TechWorkshop"],
            receiveUpdates: true,
            updates: ["Bring your own laptop", "We'll be using Flutter for cross-platform development"],
            relatedActivities: []
        ),
        Activity(
            id: UUID(),
            title: "Sunday Morning Yoga in the Park",
            category: "Sports",
            date: Date().addingTimeInterval(518400),
            location: Location(name: "New Farm Park", coordinate: CLLocationCoordinate2D(latitude: -27.4712, longitude: 153.0526)),
            currentParticipants: 10,
            maxParticipants: 20,
            host: Host(name: "Zoe Taylor", profilePicture: URL(string: "https://example.com/zoe.jpg"), rating: 4.7),
            description: "Start your Sunday with a relaxing yoga session in the beautiful New Farm Park.",
            tags: ["Yoga", "Outdoors", "Wellness"],
            receiveUpdates: true,
            updates: ["Bring your own mat", "All levels welcome"],
            relatedActivities: []
        ),
        Activity(
            id: UUID(),
            title: "Brisbane Food Truck Fiesta",
            category: "Food",
            date: Date().addingTimeInterval(604800),
            location: Location(name: "South Bank Parklands", coordinate: CLLocationCoordinate2D(latitude: -27.4785, longitude: 153.0233)),
            currentParticipants: 75,
            maxParticipants: 300,
            host: Host(name: "Foodie Events Brisbane", profilePicture: URL(string: "https://example.com/foodieevents.jpg"), rating: 4.8),
            description: "Experience a variety of cuisines from Brisbane's best food trucks all in one place!",
            tags: ["FoodTrucks", "StreetFood", "FoodFestival"],
            receiveUpdates: true,
            updates: ["New truck added: Taco Fiesta", "Live music from 6 PM"],
            relatedActivities: []
        ),
        Activity(
            id: UUID(),
            title: "Historical Walking Tour of Brisbane",
            category: "Explore",
            date: Date().addingTimeInterval(691200),
            location: Location(name: "City Hall", coordinate: CLLocationCoordinate2D(latitude: -27.4686, longitude: 153.0234)),
            currentParticipants: 8,
            maxParticipants: 15,
            host: Host(name: "Brisbane History Society", profilePicture: URL(string: "https://example.com/brishistory.jpg"), rating: 4.6),
            description: "Discover the rich history of Brisbane on this guided walking tour of the city center.",
            tags: ["History", "Walking", "CityTour"],
            receiveUpdates: true,
            updates: ["Tour will last approximately 2 hours", "Wear comfortable walking shoes"],
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
