import Foundation

struct User: Identifiable, Codable, Equatable {
    var id: String
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
}

extension User {
    static var sampleUser: User {
        User(id: UUID().uuidString, username: "sampleuser", email: "sample@example.com", fullName: "Sample User", bio: "This is a sample user", interests: ["Coding", "SwiftUI"], profileImageURL: nil, joinDate: Date(), activities: [])
    }
}
