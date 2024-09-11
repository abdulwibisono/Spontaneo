import Foundation
import SwiftUI

enum TabBarItem: Hashable {
    case home, rewards, profile, activities
    
    var iconName: String {
        switch self {
            case .home: return "house"
            case .rewards: return "gift"
            case .activities: return "figure.walk"
            case .profile: return "person"
        }
    }
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .rewards: return "Rewards"
        case .activities: return "Activities"
        case .profile: return "Profile"
        }
    }
    
    var color: Color {
        switch self {
        case .home: return Color.red
        case .rewards: return Color.blue
        case .activities: return Color.orange
        case .profile: return Color.green
        }
    }
}
