import Foundation

struct Reward: Identifiable {
    let id: UUID = UUID()
    let title: String
    let description: String
    let discount: String
    let businessName: String
    let isRedeemed: Bool
    let expirationDate: Date
    let logoURL: URL?
    let websiteURL: URL?
    let address: String
}

let sampleRewards = [
    Reward(title: "15% off Coffee", description: "Enjoy a 15% discount on your favorite coffee", discount: "15%", businessName: "Starbucks", isRedeemed: false, expirationDate: Date().addingTimeInterval(7*24*60*60), logoURL: URL(string: "https://example.com/starbucks-logo.png"), websiteURL: URL(string: "https://www.starbucks.com"), address: "123 Main St, Brisbane QLD 4000"),
    Reward(title: "Free Pastry", description: "Get a free pastry with any drink purchase", discount: "100%", businessName: "Guzman y Gomez", isRedeemed: false, expirationDate: Date().addingTimeInterval(14*24*60*60), logoURL: URL(string: "https://example.com/gyg-logo.png"), websiteURL: URL(string: "https://www.guzmanygomez.com"), address: "456 Queen St, Brisbane QLD 4000"),
    Reward(title: "20% off Lunch", description: "Save 20% on your lunch order", discount: "20%", businessName: "Grill'd", isRedeemed: true, expirationDate: Date().addingTimeInterval(-1*24*60*60), logoURL: URL(string: "https://example.com/grilld-logo.png"), websiteURL: URL(string: "https://www.grilld.com.au"), address: "789 Edward St, Brisbane QLD 4000"),
    Reward(title: "Buy 1 Get 1 Free", description: "Buy one burger and get another for free", discount: "50%", businessName: "McDonald's", isRedeemed: false, expirationDate: Date().addingTimeInterval(10*24*60*60), logoURL: URL(string: "https://example.com/mcdonalds-logo.png"), websiteURL: URL(string: "https://www.mcdonalds.com.au"), address: "321 George St, Brisbane QLD 4000")
]