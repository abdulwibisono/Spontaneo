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
    @State private var lastDragValue: CGFloat = 0
    @State private var bottomSheetHeight: CGFloat = 150

    // Add these state variables
    @State private var collapsedOffset: CGFloat = 0
    @State private var expandedOffset: CGFloat = 0
    let desiredExpandedHeight: CGFloat = 500

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Map(coordinateRegion: $region, showsUserLocation: true, userTrackingMode: $userTrackingMode)
                    .edgesIgnoringSafeArea(.all)
                    .onAppear {
                        if let location = locationManager.location {
                            region.center = location.coordinate
                        }
                        // Initialize collapsed and expanded offsets
                        collapsedOffset = geometry.size.height - bottomSheetHeight
                        expandedOffset = geometry.size.height - bottomSheetHeight - desiredExpandedHeight
                        bottomSheetOffset = collapsedOffset
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
                    .offset(y: bottomSheetOffset)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let dragAmount = value.translation.height - lastDragValue
                                bottomSheetOffset += dragAmount
                                // Clamp the offset between expanded and collapsed positions
                                bottomSheetOffset = max(expandedOffset, min(bottomSheetOffset, collapsedOffset))
                                lastDragValue = value.translation.height
                            }
                            .onEnded { value in
                                lastDragValue = 0
                                let threshold: CGFloat = (collapsedOffset - expandedOffset) / 2
                                withAnimation {
                                    if bottomSheetOffset < collapsedOffset - threshold {
                                        bottomSheetOffset = expandedOffset
                                    } else {
                                        bottomSheetOffset = collapsedOffset
                                    }
                                }
                            }
                    )
            }
            .navigationTitle("Home")
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
                .padding(.top, -14)
                .fontWeight(.bold)
            
            Spacer()
            
            VStack {
                HStack {
                    ZStack {
                        Rectangle()
                    }
                }
            }
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
