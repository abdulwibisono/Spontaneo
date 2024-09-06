import Foundation

struct Reward: Identifiable {
    let id: UUID = UUID()
    let title: String
    let description: String
    let discount: String
    let businessName: String
    let isRedeemed: Bool
    let expirationDate: Date
}

let sampleRewards = [
    Reward(title: "10% off Coffee", description: "Get 10% off your next coffee purchase", discount: "10%", businessName: "UQ Coffee Shop", isRedeemed: false, expirationDate: Date().addingTimeInterval(7*24*60*60)),
    Reward(title: "Free Pastry", description: "Enjoy a free pastry with any drink purchase", discount: "100%", businessName: "Brisbane Bakery", isRedeemed: false, expirationDate: Date().addingTimeInterval(14*24*60*60)),
    Reward(title: "20% off Lunch", description: "Save 20% on your lunch order", discount: "20%", businessName: "Student Deli", isRedeemed: true, expirationDate: Date().addingTimeInterval(-1*24*60*60)),
    Reward(title: "Buy 1 Get 1 Free", description: "Buy one meal and get another for free", discount: "50%", businessName: "Uni Bistro", isRedeemed: false, expirationDate: Date().addingTimeInterval(10*24*60*60))
]