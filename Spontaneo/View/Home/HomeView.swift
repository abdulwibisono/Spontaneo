import SwiftUI

struct HomeView: View {
    
    @State var selectedCategory = ""
    
    var body: some View {
        
        HeaderView()
        
        ZStack {
            MapView().overlay(
                CategoryListView
                    .padding(.top, 20),
                alignment: .top
            )
            
            VStack {
                Spacer()
                
                HotSpots
            }
        }
    }
    
    var HotSpots: some View {
        VStack {
            Text("What's in the Area")
                .bold()
            
            HStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        HStack {
                            ZStack {
                                Rectangle()
                                    .frame(width: 100, height: 100)
                                    .background(Color.white)
                                    .cornerRadius(15)
                            }
                            
                            ZStack {
                                Rectangle()
                                    .frame(width: 100, height: 100)
                                    .colorEffect(<#T##shader: Shader##Shader#>, isEnabled: true)
                                    .cornerRadius(15)
                            }
                            
                            ZStack {
                                Rectangle()
                                    .frame(width: 100, height: 100)
                                    .background(Color.white)
                                    .cornerRadius(15)
                            }
                            
                            ZStack {
                                Rectangle()
                                    .frame(width: 100, height: 100)
                                    .background(Color.white)
                                    .cornerRadius(15)
                            }
                        }
                        .padding(15)
                    }
                }
            }
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
                                .white)
                        .clipShape(Capsule())
                    }
                }
                .padding(.leading)
                .padding(.trailing)
            }
        }
    }
}

#Preview {
    HomeView()
}
