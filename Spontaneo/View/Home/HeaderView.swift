import SwiftUI
import UIKit
import SafariServices

struct HeaderView: View {
    
    @State private var searchText = ""
    @State var selectedCategory = ""
    @State private var showSearchResults = false
    
    var body: some View {
        HStack {
            VStack {
                HStack {
                    Text("**Spontaneo**")
                        .font(.system(size:30))
                        .frame(width: 200)
                        .padding(.leading, -10)
                    
                    Spacer()
                    
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size:30))
                        .frame(width: 200)
                        .padding(.trailing, -50)
                }
                
                CategoryListView
                
            }.navigationBarBackButtonHidden(true)
        }
    }
    
    var CategoryListView: some View {
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
        }
    }
}
