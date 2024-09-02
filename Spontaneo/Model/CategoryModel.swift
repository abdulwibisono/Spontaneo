import SwiftUI

struct CategoryModel: Identifiable, Hashable {
    var id: UUID = .init()
    var icon: String
    var title: String
}

var categoryList: [CategoryModel] = [
    CategoryModel(icon: "cup.and.saucer.fill", title: "Coffee"),
    CategoryModel(icon: "book.fill", title: "Study"),
    CategoryModel(icon: "gym.bag.fill", title: "Fitness"),
    CategoryModel(icon: "gamecontroller.fill", title: "Game"),
]
