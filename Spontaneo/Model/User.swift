import Foundation

struct User: Identifiable, Codable, Equatable {
    let id: String
    var username: String
    var email: String
    var fullName: String
    var bio: String
    var interests: [String]
    var profileImageURL: URL?
    var joinDate: Date
    var activities: [ActivityReference]

    struct ActivityReference: Codable, Equatable {
        let id: String
        let title: String
        let date: Date
    }

    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }

    static var sampleUser: User {
        User(id: "sample",
             username: "johndoe",
             email: "john@example.com",
             fullName: "John Doe",
             bio: "I love outdoor activities!",
             interests: ["Hiking", "Photography", "Cooking"],
             profileImageURL: URL(string: "https://example.com/profile.jpg"),
             joinDate: Date(),
             activities: [
                ActivityReference(id: "act1", title: "Hiking Trip", date: Date()),
                ActivityReference(id: "act2", title: "Cooking Class", date: Date())
             ])
    }
}
