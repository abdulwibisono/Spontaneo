import SwiftUI

struct CategoryModel: Identifiable, Hashable {
    var id: UUID = .init()
    var icon: String
    var title: String
}

func getCategoryList() -> [CategoryModel] {
    return [
        CategoryModel(icon: "square.grid.2x2.fill", title: "All"),
        CategoryModel(icon: "cup.and.saucer.fill", title: "Coffee"),
        CategoryModel(icon: "book.fill", title: "Study"),
        CategoryModel(icon: "sportscourt.fill", title: "Sports"),
        CategoryModel(icon: "fork.knife", title: "Food"),
        CategoryModel(icon: "binoculars.fill", title: "Explore"),
        CategoryModel(icon: "music.note", title: "Music"),
        CategoryModel(icon: "paintpalette.fill", title: "Art"),
        CategoryModel(icon: "laptopcomputer", title: "Tech"),
        CategoryModel(icon: "leaf.fill", title: "Outdoor"),
        CategoryModel(icon: "figure.walk", title: "Fitness"),
        CategoryModel(icon: "gamecontroller.fill", title: "Games"),
        CategoryModel(icon: "airplane", title: "Travel"),
        CategoryModel(icon: "calendar.circle.fill", title: "Events"),
        CategoryModel(icon: "tshirt.fill", title: "Fashion"),
        CategoryModel(icon: "heart.fill", title: "Health"),
        CategoryModel(icon: "books.vertical.fill", title: "Books"),
        CategoryModel(icon: "film.fill", title: "Movies"),   
    ]
}
