import SwiftUI
import CoreLocation
import MapKit

struct Hotspot: Identifiable, Equatable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let activityCount: Int
    
    static func == (lhs: Hotspot, rhs: Hotspot) -> Bool {
        lhs.id == rhs.id && 
        lhs.coordinate.latitude == rhs.coordinate.latitude &&
        lhs.coordinate.longitude == rhs.coordinate.longitude &&
        lhs.activityCount == rhs.activityCount
    }
}

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
    @State private var hotspots: [Hotspot] = []
    @State private var isMapLoaded = false
    @State private var showLocationButton = false
    @State private var selectedHotspot: Hotspot?

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                mapView
                    .edgesIgnoringSafeArea(.all)
                    .onAppear {
                        setupInitialState(geometry: geometry)
                    }
                
                VStack {
                    searchBar
                    CategoryListView
                        .padding(.top, 20)
                    Spacer()
                }
                .padding(.top, 60)
                
                locationButton
                
                BottomSheetView(activities: activities)
                    .offset(y: bottomSheetOffset)
                    .gesture(dragGesture)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: bottomSheetOffset)
            }
        }
        .accentColor(Color("AccentColor"))
    }
    
    private var mapView: some View {
        Map(coordinateRegion: $region, showsUserLocation: true, userTrackingMode: $userTrackingMode, annotationItems: hotspots) { hotspot in
            MapAnnotation(coordinate: hotspot.coordinate) {
                HotspotAnnotationView(hotspot: hotspot, isSelected: selectedHotspot == hotspot)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            region.center = hotspot.coordinate
                            region.span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                            selectedHotspot = hotspot
                        }
                    }
            }
        }
        .mapStyle(.standard(elevation: .realistic))
        .overlay(
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 40, height: 40)
                .scaleEffect(isMapLoaded ? 1 : 0)
                .opacity(isMapLoaded ? 0 : 1)
                .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isMapLoaded)
        )
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    isMapLoaded = true
                }
            }
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color("AccentColor"))
            Text("Search for activities...")
                .foregroundColor(Color("NeutralDark").opacity(0.6))
            Spacer()
        }
        .padding()
        .background(Color("NeutralLight"))
        .cornerRadius(20)
        .shadow(color: Color("NeutralDark").opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
    
    private var locationButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: centerOnUserLocation) {
                    Image(systemName: "location.fill")
                        .padding()
                        .background(Color("NeutralLight"))
                        .foregroundColor(Color("AccentColor"))
                        .clipShape(Circle())
                        .shadow(color: Color("NeutralDark").opacity(0.2), radius: 5, x: 0, y: 2)
                }
                .padding(.trailing)
                .opacity(showLocationButton ? 1 : 0)
                .scaleEffect(showLocationButton ? 1 : 0.5)
                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: showLocationButton)
            }
            .padding(.bottom, 100)
        }
    }
    
    private var dragGesture: some Gesture {
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
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    if bottomSheetOffset < collapsedOffset - threshold {
                        bottomSheetOffset = expandedOffset
                    } else {
                        bottomSheetOffset = collapsedOffset
                    }
                }
            }
    }
    
    private func setupInitialState(geometry: GeometryProxy) {
        if let location = locationManager.location {
            region.center = location.coordinate
        }
        collapsedOffset = geometry.size.height - bottomSheetHeight
        expandedOffset = geometry.size.height - bottomSheetHeight - desiredExpandedHeight
        bottomSheetOffset = collapsedOffset
        fetchNearbyActivities()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation {
                showLocationButton = true
            }
        }
    }
    
    private func centerOnUserLocation() {
        if let location = locationManager.location {
            withAnimation(.easeInOut(duration: 0.5)) {
                region.center = location.coordinate
                userTrackingMode = .follow
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
                calculateHotspots()
            } else {
                self.activities = fetchedActivities
                calculateHotspots()
            }
        }
    }
    
    private func calculateHotspots() {
        let gridSize = 0.005 // Approximately 500 meters
        var hotspotDict: [String: [Activity]] = [:]
        
        for activity in activities {
            let lat = Double(Int(activity.location.latitude / gridSize)) * gridSize
            let lon = Double(Int(activity.location.longitude / gridSize)) * gridSize
            let key = "\(lat),\(lon)"
            
            if hotspotDict[key] != nil {
                hotspotDict[key]?.append(activity)
            } else {
                hotspotDict[key] = [activity]
            }
        }
        
        hotspots = hotspotDict.compactMap { (key, activities) in
            guard activities.count >= 2 else { return nil }
            let parts = key.split(separator: ",")
            guard let lat = Double(parts[0]), let lon = Double(parts[1]) else { return nil }
            return Hotspot(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon), activityCount: activities.count)
        }
    }
    
    @ViewBuilder
    func BottomSheetView(activities: [Activity]) -> some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color("NeutralDark").opacity(0.3))
                .frame(width: 40, height: 6)
                .padding(.top, 8)
            
            Text("What's in the Area")
                .font(.headline)
                .foregroundColor(Color("NeutralDark"))
                .padding()
            
            if activities.isEmpty {
                emptyStateView
            } else {
                activityList
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color("NeutralLight"))
        .cornerRadius(20)
        .shadow(color: Color("NeutralDark").opacity(0.1), radius: 10, x: 0, y: -5)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "mappin.slash")
                .font(.system(size: 50))
                .foregroundColor(Color("AccentColor"))
            Text("No activities nearby")
                .font(.headline)
            Text("Try expanding your search area or create a new activity!")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(Color("NeutralDark").opacity(0.7))
        }
        .padding()
        .frame(height: 300)
    }
    
    private var activityList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(activities) { activity in
                    NavigationLink(destination: ActivityDetailedView(activity: activity, activityService: activityService)) {
                        ActivityCardHome(activity: activity)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .transition(.opacity.combined(with: .slide))
                }
            }
            .padding(.horizontal)
            .padding(.top)
        }
    }
    
    var CategoryListView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(categoryList, id: \.id) { item in
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedCategory = item.title
                        }
                    }) {
                        HStack {
                            Image(systemName: item.icon)
                            Text(item.title)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(selectedCategory == item.title ? Color("AccentColor") : Color("NeutralLight"))
                        .foregroundColor(selectedCategory == item.title ? Color("NeutralLight") : Color("NeutralDark"))
                        .cornerRadius(20)
                        .shadow(color: Color("NeutralDark").opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                    .scaleEffect(selectedCategory == item.title ? 1.05 : 1)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedCategory)
                }
            }
            .padding(.horizontal)
        }
    }
}

struct HotspotAnnotationView: View {
    let hotspot: Hotspot
    let isSelected: Bool
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color("AccentColor").opacity(0.3))
                .frame(width: CGFloat(hotspot.activityCount * 15), height: CGFloat(hotspot.activityCount * 15))
            
            Circle()
                .stroke(Color("AccentColor"), lineWidth: 2)
                .frame(width: CGFloat(hotspot.activityCount * 15), height: CGFloat(hotspot.activityCount * 15))
            
            Text("\(hotspot.activityCount)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(Color("NeutralLight"))
                .padding(8)
                .background(Color("AccentColor"))
                .clipShape(Circle())
        }
        .scaleEffect(isAnimating ? 1.1 : 1)
        .scaleEffect(isSelected ? 1.2 : 1)
        .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isAnimating)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        .onAppear {
            isAnimating = true
        }
    }
}

struct ActivityCardHome: View {
    let activity: Activity
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "photo")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 80)
                .cornerRadius(8)
                .background(Color("NeutralDark").opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.title)
                    .font(.headline)
                    .foregroundColor(Color("NeutralDark"))
                    .lineLimit(1)
                
                Text(activity.description)
                    .font(.subheadline)
                    .foregroundColor(Color("NeutralDark").opacity(0.8))
                    .lineLimit(2)
                
                HStack {
                    Image(systemName: "mappin.circle.fill")
                    Text("1.2 km away")
                }
                .font(.caption)
                .foregroundColor(Color("AccentColor"))
            }
            
            Spacer()
        }
        .padding()
        .background(Color("NeutralLight"))
        .cornerRadius(12)
        .shadow(color: Color("NeutralDark").opacity(isHovered ? 0.2 : 0.1), radius: isHovered ? 8 : 5, x: 0, y: isHovered ? 4 : 2)
        .scaleEffect(isHovered ? 1.02 : 1)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}