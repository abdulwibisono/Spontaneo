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
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $region, showsUserLocation: true, userTrackingMode: $userTrackingMode)
                .edgesIgnoringSafeArea(.all)
                .bottomSheet(presentationDetents: [.medium, .large, .height(70)], isPresented: .constant(true), sheetCornerRadius: 20) {
                    ScrollView (.vertical, showsIndicators: false) {
                        VStack (spacing: 15) {
                            Text("What's in the Area")
                                .padding(.vertical, 10)
                                .padding(.horizontal)
                            
                            HotSpot()
                        }
                        .padding()
                        .padding(.top)
                    }
                } onDismiss: {}
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
}

#Preview{
    HomeView()
}
