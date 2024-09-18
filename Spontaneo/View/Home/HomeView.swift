import SwiftUI
import CoreLocation
import MapKit

struct HomeView: View {
    @State var selectedCategory = ""
    @StateObject private var locationManager = LocationManager()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.3352, longitude: -122.0096),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var userTrackingMode: MapUserTrackingMode = .follow
    @State private var isHotSpotsPresented = false
    @State private var bottomSheetOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Map(coordinateRegion: $region, showsUserLocation: true, userTrackingMode: $userTrackingMode)
                    .edgesIgnoringSafeArea(.all)
                    .onAppear {
                        if let location = locationManager.location {
                            region.center = location.coordinate
                        }
                    }
                    .overlay(
                        VStack {
                            HStack {
                                Spacer()
                                Button(action: {
                                    if let location = locationManager.location {
                                        withAnimation {
                                            region.center = location.coordinate
                                            userTrackingMode = .follow
                                        }
                                    }
                                }) {
                                    Image(systemName: "location.fill")
                                        .padding()
                                        .background(Color.white)
                                        .clipShape(Circle())
                                        .shadow(radius: 4)
                                }
                                .padding(.trailing)
                            }
                            .padding(.bottom)
                            .padding(.top, 120)
                            Spacer()
                        }
                    )
                
                VStack {
                    CategoryListView
                        .padding(.top, 20)
                    
                    Spacer()
                }
                
                BottomSheetView()
                    .offset(y: geometry.size.height - 150 + bottomSheetOffset) // Adjust the offset as needed
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                bottomSheetOffset = value.translation.height
                            }
                            .onEnded { value in
                                if value.translation.height > 100 {
                                    bottomSheetOffset = geometry.size.height - 100
                                } else {
                                    bottomSheetOffset = 0
                                }
                            }
                    )
            }
        }
    }
    
    @ViewBuilder
    func HotSpot() -> some View {
        VStack {
            HStack {
                Rectangle()
                    .foregroundColor(.gray)
                    .frame(width: 70, height:50)
                
                Rectangle()
                    .foregroundColor(.gray)
                    .frame(width: 70, height:50)
            }
            
            HStack {
                Rectangle()
                    .foregroundColor(.gray)
                    .frame(width: 70, height:50)
                
                Rectangle()
                    .foregroundColor(.gray)
                    .frame(width: 70, height:50)
            }
        }
        .padding(.top, 20)
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
                        .background(selectedCategory == item.title ? .cyan : .white)
                        .clipShape(Capsule())
                    }
                }
                .padding(.horizontal)
            }
        }.padding(.top, 40)
    }
    
    @ViewBuilder
    func BottomSheetView() -> some View {
        VStack {
            Capsule()
                .frame(width: 40, height: 6)
                .foregroundColor(Color.gray.opacity(0.5))
                .padding(.top, 8)
            
            Text("What's in the Area")
                .padding()
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 10)
    }
}

#Preview {
    HomeView()
}
