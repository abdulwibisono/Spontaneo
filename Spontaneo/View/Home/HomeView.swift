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
                
                Button(action: {
                    isHotSpotsPresented.toggle()
                }) {
                    Text("What's in the Area")
                        .padding()
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(radius: 5)
                }
                .padding(.bottom, 100)
            }
            
            HotSpotsSlideUpView(isPresented: $isHotSpotsPresented)
                .edgesIgnoringSafeArea(.bottom)
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
