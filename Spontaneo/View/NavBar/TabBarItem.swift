import Foundation
import SwiftUI

enum TabBarItem: Hashable {
    case home, rewards, profile, activites
    
    var iconName: String {
        switch self {
        case .home: return "house"
        case .rewards: return "gift"
        case .activites: return "message"
        case .profile: return "person"
        }
    }
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .rewards: return "Favorites"
        case .activites: return "Messages"
        case .profile: return "Profile"
        }
    }
    
    var color: Color {
        switch self {
        case .home: return Color.red
        case .rewards: return Color.blue
        case .activites: return Color.orange
        case .profile: return Color.green
        }
    }
}
