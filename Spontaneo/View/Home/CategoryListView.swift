import UIKit
import SwiftUI

struct CategoryListView: View {
    
    @State var selectedCategory = ""
    
    var body: some View {
        HStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(categoryList, id: \.id) { item in
                        HStack {
                            Image(systemName: item.icon)
                                .foregroundColor(selectedCategory == item.title ? .white : .black)
                            
                            Text(item.title)
                                .foregroundColor(selectedCategory == item.title ? .white : .black)
                        }
                        .padding(15)
                        .background(selectedCategory == item.title ? .cyan :
                                .gray.opacity(0.1))
                        .clipShape(Capsule())
                    }
                }
                .padding(.leading)
                .padding(.trailing)
            }
        }.padding(.top, 20)
    }
}
