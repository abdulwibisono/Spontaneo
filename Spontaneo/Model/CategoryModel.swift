import SwiftUI

struct CategoryModel: Identifiable, Hashable {
    var id: UUID = .init()
    var icon: String
    var title: String
}

var categoryList: [CategoryModel] = [
    CategoryModel(icon: "storefront.fill", title: "Store"),
    CategoryModel(icon: "fork.knife", title: "Restaurants"),
    CategoryModel(icon: "cart.fill", title: "Convenience"),
    CategoryModel(icon: "hands.and.sparkles.fill", title: "Place of Worship"),
]
