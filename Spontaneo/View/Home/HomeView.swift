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
                        .padding(.top, 90)
                        Spacer()
                    }
            )
            
            VStack {
                CategoryListView
                .padding(.top, 20)
                
                Spacer()
                
                HeaderView()
            }
        }
    }
    
    var HotSpots: some View {
        VStack {
            Text("What's in the Area")
                .bold()
                .padding(.leading, -164)
                .font(.system(size: 24))
            
            HStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        HStack {
                            ZStack {
                                Rectangle()
                                    .frame(width: 200, height: 100)
                                    .foregroundColor(.white)
                                    .cornerRadius(15)
                            }
                            
                            ZStack {
                                Rectangle()
                                    .frame(width: 200, height: 100)
                                    .foregroundColor(.white)
                                    .cornerRadius(15)
                            }
                            
                            ZStack {
                                Rectangle()
                                    .frame(width: 200, height: 100)
                                    .foregroundColor(.white)
                                    .cornerRadius(15)
                            }
                            
                            ZStack {
                                Rectangle()
                                    .frame(width: 200, height: 100)
                                    .foregroundColor(.white)
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
