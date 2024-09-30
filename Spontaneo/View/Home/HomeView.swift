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
    @State private var collapsedOffset: CGFloat = 0
    @State private var expandedOffset: CGFloat = 0
    let desiredExpandedHeight: CGFloat = 500

    @StateObject private var activityService = ActivityService()
    @State private var activities: [Activity] = []

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Map(coordinateRegion: $region, showsUserLocation: true, userTrackingMode: $userTrackingMode)
                    .edgesIgnoringSafeArea(.all)
                    .onAppear {
                        if let location = locationManager.location {
                            region.center = location.coordinate
                        }
                        collapsedOffset = geometry.size.height - bottomSheetHeight
                        expandedOffset = geometry.size.height - bottomSheetHeight - desiredExpandedHeight
                        bottomSheetOffset = collapsedOffset
                        fetchNearbyActivities()
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
                
                BottomSheetView(activities: activities)
                    .offset(y: bottomSheetOffset)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let dragAmount = value.translation.height - lastDragValue
                                bottomSheetOffset += dragAmount
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
        }
    }
    
    private func fetchNearbyActivities() {
        activityService.getAllActivities { fetchedActivities in
            if let userLocation = locationManager.location {
                self.activities = fetchedActivities.filter { activity in
                    let activityLocation = CLLocation(latitude: activity.location.latitude, longitude: activity.location.longitude)
                    let distanceInMeters = userLocation.distance(from: activityLocation)
                    let distanceInKm = distanceInMeters / 1000
                    return distanceInKm <= 1
                }
            } else {
                self.activities = fetchedActivities
            }
        }
    }
    
    @ViewBuilder
    func BottomSheetView(activities: [Activity]) -> some View {
        VStack {
            Capsule()
                .frame(width: 40, height: 6)
                .foregroundColor(Color.gray.opacity(0.5))
                .padding(.top, 8)
            
            Text("What's in the Area")
                .padding()
                .padding(.top, -14)
                .fontWeight(.bold)
            
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(activities) { activity in
                        NavigationLink(destination: ActivityDetailedView(activity: activity, activityService: activityService)) {
                            ActivityCardHome(activity: activity)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
                .padding(.top)
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 10)
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

struct ActivityCardHome: View {
    let activity: Activity
    
    var body: some View {
        HStack {
            Spacer()
            
            ZStack {
                Rectangle()
                    .frame(width: 170, height: 120)
                    .cornerRadius(12)
                    .opacity(0.5)
                
                Text(activity.title)
            }
            
            Spacer()
        }
    }
}
