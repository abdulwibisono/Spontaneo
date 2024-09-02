//import SwiftUI
//import Combine
//
//class HomeViewModel: ObservableObject {
//    
//    // Published properties to update the UI
//    @Published var activities: [Activity] = []
//    @Published var featuredActivities: [Activity] = []
//    @Published var categories: [Category] = []
//    
//    private var cancellables = Set<AnyCancellable>()
//    
//    // MARK: - Init
//    init() {
//        fetchCategories()
//    }
//    
//    // MARK: - Fetch Activities
//    func fetchActivities() {
//        // Simulating data fetch with mock data
//        // Replace this with actual Firebase or backend calls
//        
//        let sampleActivities = [
//            Activity(id: UUID(), name: "Morning Coffee Meetup", imageName: "coffee", dateString: "Tomorrow, 8:00 AM"),
//            Activity(id: UUID(), name: "Cycling Adventure", imageName: "bike", dateString: "Today, 6:00 PM"),
//            Activity(id: UUID(), name: "Book Reading Session", imageName: "book", dateString: "Saturday, 4:00 PM"),
//            Activity(id: UUID(), name: "Cooking Class", imageName: "cooking", dateString: "Friday, 5:00 PM")
//        ]
//        
//        // Assign fetched data
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
//            self?.activities = sampleActivities
//            self?.featuredActivities = Array(sampleActivities.prefix(3)) // First 3 as featured
//        }
//    }
//    
//    // MARK: - Fetch Categories
//    func fetchCategories() {
//        // Simulating category data
//        let sampleCategories = [
//            Category(id: UUID(), name: "Coffee", icon: "cup.and.saucer.fill", colorStart: .orange, colorEnd: .yellow),
//            Category(id: UUID(), name: "Cycling", icon: "bicycle", colorStart: .green, colorEnd: .blue),
//            Category(id: UUID(), name: "Reading", icon: "book.fill", colorStart: .red, colorEnd: .pink),
//            Category(id: UUID(), name: "Cooking", icon: "fork.knife", colorStart: .purple, colorEnd: .blue),
//            Category(id: UUID(), name: "Fitness", icon: "flame.fill", colorStart: .red, colorEnd: .orange),
//            Category(id: UUID(), name: "Music", icon: "music.note", colorStart: .blue, colorEnd: .purple)
//        ]
//        
//        // Assign fetched data
//        DispatchQueue.main.async { [weak self] in
//            self?.categories = sampleCategories
//        }
//    }
//}
