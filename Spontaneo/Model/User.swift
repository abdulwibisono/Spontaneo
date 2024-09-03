import Foundation

struct User: Identifiable, Codable, Equatable {
    let id: String
    var username: String
    var email: String
    var fullName: String
    var bio: String
    var profileImageURL: URL?
    var interests: [String]
    var joinDate: Date
    
    enum CodingKeys: String, CodingKey {
        case id, username, email, fullName, bio, profileImageURL, interests, joinDate
    }
    
    init(id: String = UUID().uuidString,
         username: String,
         email: String,
         fullName: String,
         bio: String = "",
         profileImageURL: URL? = nil,
         interests: [String] = [],
         joinDate: Date = Date()) {
        self.id = id
        self.username = username
        self.email = email
        self.fullName = fullName
        self.bio = bio
        self.profileImageURL = profileImageURL
        self.interests = interests
        self.joinDate = joinDate
    }
}
