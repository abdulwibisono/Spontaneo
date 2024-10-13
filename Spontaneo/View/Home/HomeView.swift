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

    @State private var isSearching = false
    @State private var searchText = ""
    @State private var isMapExpanded = false
    @Namespace private var animation
    
    @State private var selectedCategory: CategoryModel? {
        didSet {
            calculateHotspots()
        }
    }
    @State private var categories: [CategoryModel] = getCategoryList()
    @State private var isFilterExpanded = false

    // Add this to the existing state variables
    @State private var mapStyle: MapStyle = .standard
    @State private var showNearbyActivityAlert = false
    @State private var nearbyActivity: Activity?

    @State private var zoomLevel: Double = 0.05
    
    @State private var searchResults: [Activity] = []
    
    // Add these to the existing state variables
    @State private var nearbyHotspot: Hotspot?
    @State private var showHotspotNotification = false
    @State private var isInsideHotspot = false

    @State private var showHotspotDetail = false
    @State private var selectedHotspotActivities: [Activity] = []
    @State private var lastRecalculationLocation: CLLocation?

    @State private var lastNotificationTime: Date?
    @State private var lastNotifiedHotspotId: UUID?

    @State private var dismissedHotspots: Set<UUID> = []
    @State private var selectedActivity: Activity?
    @State private var showActivityDetail = false

    var filteredActivities: [Activity] {
        guard let selectedCategory = selectedCategory, selectedCategory.title != "All" else {
            return activities
        }
        return activities.filter { $0.category == selectedCategory.title }
    }
    
    // Change this from private to static
    static func iconForCategory(_ category: String) -> String {
        switch category {
        case "Coffee":
            return "cup.and.saucer.fill"
        case "Study":
            return "book.fill"
        case "Sports":
            return "sportscourt.fill"
        case "Food":
            return "fork.knife"
        case "Explore":
            return "binoculars.fill"
        case "Music":
            return "music.note"
        case "Art":
            return "paintpalette.fill"
        case "Tech":
            return "laptopcomputer"
        case "Outdoor":
            return "leaf.fill"
        case "Fitness":
            return "figure.walk"
        case "Games":
            return "gamecontroller.fill"
        case "Travel":
            return "airplane"
        case "Events":
            return "calendar.circle.fill"
        case "Fashion":
            return "tshirt.fill"
        case "Health":
            return "heart.fill"
        case "Books":
            return "books.vertical.fill"
        case "Movies":
            return "film.fill"
        default:
            return "star.fill"
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                mapView
                    .edgesIgnoringSafeArea(.all)
                    .onAppear {
                        setupInitialState(geometry: geometry)
                        checkNearbyActivities()
                        
                        // Add this timer to periodically check for nearby hotspots
                        Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
                            checkNearbyHotspots()
                        }
                    }
                
                VStack(spacing: 0) {
                    HStack(spacing: 16) {
                        filterButton
                        Spacer()
                        searchButton
                        mapStyleButton
                    }
                    .padding(.top, 60)
                    .padding(.horizontal)
                    
                    if isFilterExpanded {
                        CategoryListView
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    if isSearching {
                        searchBarView
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    Spacer()
                }
                
                locationButton
                
                BottomSheetView(activities: filteredActivities)
                    .offset(y: bottomSheetOffset)
                    .gesture(dragGesture)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: bottomSheetOffset)
                
                if showHotspotNotification, let hotspot = nearbyHotspot {
                    VStack {
                        Spacer()
                        HotspotNotificationView(
                            hotspot: hotspot,
                            isInside: isInsideHotspot,
                            onDismiss: dismissHotspotNotification
                        )
                        .padding(.horizontal)
                        .padding(.bottom, 100)
                    }
                    .transition(.move(edge: .bottom))
                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: showHotspotNotification)
                }
                
                if showHotspotDetail, let selectedHotspot = selectedHotspot {
                    HotspotDetailView(
                        hotspot: selectedHotspot,
                        activities: selectedHotspotActivities,
                        onDismiss: {
                            withAnimation {
                                showHotspotDetail = false
                            }
                        },
                        selectedActivity: $selectedActivity,
                        showActivityDetail: $showActivityDetail
                    )
                    .frame(width: geometry.size.width * 0.9, height: geometry.size.height * 0.7)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    .transition(.opacity.combined(with: .scale))
                }
            }
            .onChange(of: locationManager.location) { newLocation in
                if let newLocation = newLocation {
                    checkAndRecalculateHotspots(newLocation: newLocation)
                }
            }
        }
        .accentColor(Color("AccentColor"))
    }
    
    private var mapView: some View {
        GeometryReader { geometry in
            Map(coordinateRegion: Binding(
                get: { self.region },
                set: { newRegion in
                    self.region = newRegion
                    self.zoomLevel = Double(newRegion.span.latitudeDelta)
                }
            ), showsUserLocation: true, userTrackingMode: $userTrackingMode, annotationItems: zoomLevel <= 0.02 ? filteredActivities : []) { activity in
                MapAnnotation(coordinate: activity.location.coordinate) {
                    ActivityPin(activity: activity, isHighlighted: searchResults.contains(where: { $0.id == activity.id }))
                        .onTapGesture {
                            selectedActivity = activity
                            showActivityDetail = true
                        }
                }
            }
            .overlay(
                ForEach(hotspots) { hotspot in
                    if zoomLevel > 0.02 {
                        HotspotAnnotationView(hotspot: hotspot, isSelected: selectedHotspot == hotspot, zoomLevel: zoomLevel)
                            .position(
                                x: geometry.size.width * (hotspot.coordinate.longitude - region.center.longitude) / region.span.longitudeDelta + geometry.size.width / 2,
                                y: geometry.size.height * (region.center.latitude - hotspot.coordinate.latitude) / region.span.latitudeDelta + geometry.size.height / 2
                            )
                            .onTapGesture {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                    region.center = hotspot.coordinate
                                    region.span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                                    selectedHotspot = hotspot
                                    selectedHotspotActivities = getActivitiesForHotspot(hotspot)
                                    showHotspotDetail = true
                                }
                            }
                    }
                }
            )
            .mapStyle(mapStyle)
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
                    withAnimation(.easeInOut(duration: 1)) {
                        isMapLoaded = true
                    }
                }
            }
            .gesture(
                DragGesture().onChanged { _ in
                    withAnimation(.easeInOut) {
                        isMapExpanded = true
                    }
                }
            )
        }
        .sheet(isPresented: $showActivityDetail, content: {
            if let activity = selectedActivity {
                ActivityDetailedView(activity: activity, activityService: activityService)
            }
        })
    }
    
    private var searchButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                isSearching.toggle()
            }
        }) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color("AccentColor"))
                .padding(12)
                .background(Color("NeutralLight"))
                .clipShape(Circle())
                .shadow(color: Color("NeutralDark").opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
    
    private var searchBarView: some View {
        VStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color("AccentColor"))
                
                TextField("Search for activities...", text: $searchText)
                    .foregroundColor(Color("NeutralDark"))
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .onChange(of: searchText) { _ in
                        searchActivities()
                    }
                
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        isSearching = false
                        searchText = ""
                        searchResults = []
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color("NeutralDark").opacity(0.6))
                }
            }
            .padding()
            .background(Color("NeutralLight"))
            .cornerRadius(20)
            .shadow(color: Color("NeutralDark").opacity(0.1), radius: 5, x: 0, y: 2)
            .padding(.horizontal)
            
            if !searchResults.isEmpty {
                searchResultsView
            }
        }
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
        selectedCategory = categories.first
        
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
    
    func calculateHotspots() {
        let epsilon: Double = 0.001 // Approximately 100 meters
        let minPoints = 2 // Minimum number of points to form a cluster

        var clusters: [[Activity]] = []
        var visited = Set<String>()

        for activity in filteredActivities {
            guard let id = activity.id else { continue }
            if visited.contains(id) { continue }
            visited.insert(id)

            var cluster = [activity]
            var neighbors = findNeighbors(of: activity, within: epsilon)

            while !neighbors.isEmpty {
                let neighbor = neighbors.removeFirst()
                if let neighborId = neighbor.id, !visited.contains(neighborId) {
                    visited.insert(neighborId)
                    let newNeighbors = findNeighbors(of: neighbor, within: epsilon)
                    neighbors.append(contentsOf: newNeighbors)
                }
                cluster.append(neighbor)
            }

            if cluster.count >= minPoints {
                clusters.append(cluster)
            }
        }

        hotspots = clusters.map { cluster in
            let center = calculateClusterCenter(cluster)
            return Hotspot(coordinate: center, activityCount: cluster.count)
        }
    }

    private func findNeighbors(of activity: Activity, within epsilon: Double) -> [Activity] {
        return filteredActivities.filter { neighbor in
            guard let neighborId = neighbor.id, let activityId = activity.id, neighborId != activityId else { return false }
            let distance = calculateDistance(from: activity.location.coordinate, to: neighbor.location.coordinate)
            return distance <= epsilon
        }
    }

    private func calculateDistance(from location1: CLLocationCoordinate2D, to location2: CLLocationCoordinate2D) -> Double {
        let location1 = CLLocation(latitude: location1.latitude, longitude: location1.longitude)
        let location2 = CLLocation(latitude: location2.latitude, longitude: location2.longitude)
        return location1.distance(from: location2) / 1000 // Convert to kilometers
    }

    private func calculateClusterCenter(_ cluster: [Activity]) -> CLLocationCoordinate2D {
        let totalLat = cluster.reduce(0) { $0 + $1.location.coordinate.latitude }
        let totalLon = cluster.reduce(0) { $0 + $1.location.coordinate.longitude }
        let count = Double(cluster.count)
        return CLLocationCoordinate2D(latitude: totalLat / count, longitude: totalLon / count)
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
            
            if filteredActivities.isEmpty {
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
            EmptyStateAnimation()
                .frame(width: 200, height: 200)
            
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
                ForEach(filteredActivities) { activity in
                    NavigationLink(destination: ActivityDetailedView(activity: activity, activityService: activityService)) {
                        ActivityCardHome(activity: activity)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .transition(.asymmetric(insertion: .scale.combined(with: .opacity),
                                            removal: .scale.combined(with: .opacity)))
                }
            }
            .padding(.horizontal)
            .padding(.top)
        }
    }
    
    private var filterButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                isFilterExpanded.toggle()
                if !isFilterExpanded {
                    selectedCategory = categories.first
                }
            }
        }) {
            HStack {
                Image(systemName: "line.3.horizontal.decrease.circle")
                Text(selectedCategory?.title ?? "All")
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color("NeutralLight"))
            .foregroundColor(Color("AccentColor"))
            .cornerRadius(20)
            .shadow(color: Color("NeutralDark").opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
    
    private var CategoryListView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(categories) { category in
                    CategoryButton(
                        category: category,
                        isSelected: selectedCategory == category,
                        action: { selectCategory(category) }
                    )
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 4)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color("NeutralLight").opacity(0.9))
                .shadow(color: Color("NeutralDark").opacity(0.1), radius: 5, x: 0, y: 2)
        )
        .frame(height: 100)
        .padding(.horizontal)
    }
    
    private func selectCategory(_ category: CategoryModel) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            selectedCategory = category
            isFilterExpanded = false
            calculateHotspots()
        }
    }
    
    // Add this to the body, near the other buttons in the top bar
    private var mapStyleButton: some View {
        Menu {
            Button("Standard") { mapStyle = .standard }
            Button("Satellite") { mapStyle = .hybrid }
            Button("Hybrid") { mapStyle = .imagery(elevation: .realistic) }
        } label: {
            Image(systemName: "map")
                .foregroundColor(Color("AccentColor"))
                .padding(12)
                .background(Color("NeutralLight"))
                .clipShape(Circle())
                .shadow(color: Color("NeutralDark").opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
    
    // Add this function to check for nearby activities
    private func checkNearbyActivities() {
        guard let userLocation = locationManager.location else { return }
        
        for activity in activities {
            let activityLocation = CLLocation(latitude: activity.location.latitude, longitude: activity.location.longitude)
            let distance = userLocation.distance(from: activityLocation)
            
            if distance <= 1000 { // Within 1km
                nearbyActivity = activity
                showNearbyActivityAlert = true
                break
            }
        }
    }
    
    private func searchActivities() {
        searchResults = activities.filter { activity in
            activity.title.lowercased().contains(searchText.lowercased()) ||
            activity.description.lowercased().contains(searchText.lowercased()) ||
            activity.category.lowercased().contains(searchText.lowercased())
        }
        
        if let firstResult = searchResults.first {
            withAnimation(.easeInOut(duration: 0.5)) {
                region.center = firstResult.location.coordinate
                region.span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            }
        }
    }
    
    private var searchResultsView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(searchResults) { activity in
                    Button(action: {
                        centerMapOnActivity(activity)
                    }) {
                        HStack {
                            Image(systemName: iconForCategory(activity.category))
                                .foregroundColor(Color("AccentColor"))
                            Text(activity.title)
                                .foregroundColor(Color("NeutralDark"))
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
            .padding()
        }
        .background(Color("NeutralLight"))
        .cornerRadius(10)
        .shadow(color: Color("NeutralDark").opacity(0.1), radius: 5, x: 0, y: 2)
        .frame(maxHeight: 200)
    }
    
    private func iconForCategory(_ category: String) -> String {
        switch category {
        case "Coffee":
            return "cup.and.saucer.fill"
        case "Study":
            return "book.fill"
        case "Sports":
            return "sportscourt.fill"
        case "Food":
            return "fork.knife"
        case "Explore":
            return "binoculars.fill"
        case "Music":
            return "music.note"
        case "Art":
            return "paintpalette.fill"
        case "Tech":
            return "laptopcomputer"
        case "Outdoor":
            return "leaf.fill"
        case "Fitness":
            return "figure.walk"
        case "Games":
            return "gamecontroller.fill"
        case "Travel":
            return "airplane"
        case "Events":
            return "calendar.circle.fill"
        case "Fashion":
            return "tshirt.fill"
        case "Health":
            return "heart.fill"
        case "Books":
            return "books.vertical.fill"
        case "Movies":
            return "film.fill"
        default:
            return "star.fill"
        }
    }
    
    private func centerMapOnActivity(_ activity: Activity) {
        withAnimation(.easeInOut(duration: 0.5)) {
            region.center = activity.location.coordinate
            region.span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        }
        isSearching = false
    }
    
    // Add this function to check for nearby hotspots
    private func checkNearbyHotspots() {
        guard let userLocation = locationManager.location else { return }
        
        let now = Date()
        let cooldownPeriod: TimeInterval = 500 
        
        for hotspot in hotspots {
            let hotspotLocation = CLLocation(latitude: hotspot.coordinate.latitude, longitude: hotspot.coordinate.longitude)
            let distance = userLocation.distance(from: hotspotLocation)
            
            if distance <= 200 && !dismissedHotspots.contains(hotspot.id) { // Within 200 meters and not dismissed
                if let lastTime = lastNotificationTime,
                   let lastHotspotId = lastNotifiedHotspotId,
                   now.timeIntervalSince(lastTime) < cooldownPeriod && lastHotspotId == hotspot.id {
                    // Skip notification if cooldown period hasn't passed for this hotspot
                    continue
                }
                
                nearbyHotspot = hotspot
                isInsideHotspot = distance <= 50 // Consider inside if within 50 meters
                showHotspotNotification = true
                lastNotificationTime = now
                lastNotifiedHotspotId = hotspot.id
                break
            }
        }
    }
    
    private func checkAndRecalculateHotspots(newLocation: CLLocation) {
        guard let lastLocation = lastRecalculationLocation else {
            calculateHotspots()
            lastRecalculationLocation = newLocation
            return
        }
        
        let distance = newLocation.distance(from: lastLocation)
        if distance > 500 { // Recalculate if the user has moved more than 500 meters
            calculateHotspots()
            lastRecalculationLocation = newLocation
        }
    }
    
    private func getActivitiesForHotspot(_ hotspot: Hotspot) -> [Activity] {
        return filteredActivities.filter { activity in
            let activityLocation = CLLocation(latitude: activity.location.latitude, longitude: activity.location.longitude)
            let hotspotLocation = CLLocation(latitude: hotspot.coordinate.latitude, longitude: hotspot.coordinate.longitude)
            return activityLocation.distance(from: hotspotLocation) <= 200 // Activities within 200 meters of the hotspot
        }
    }
    
    private func dismissHotspotNotification() {
        withAnimation {
            showHotspotNotification = false
            if let hotspot = nearbyHotspot {
                dismissedHotspots.insert(hotspot.id)
            }
        }
    }
}

struct CategoryButton: View {
    let category: CategoryModel
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: category.icon)
                    .font(.system(size: 16))
                Text(category.title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .frame(width: 60, height: 60)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color("AccentColor") : Color("NeutralLight"))
            )
            .foregroundColor(isSelected ? Color("NeutralLight") : Color("NeutralDark"))
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

struct ActivityPin: View {
    let activity: Activity
    let isHighlighted: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: iconForCategory(activity.category))
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(isHighlighted ? Color.yellow : Color("AccentColor"))
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                )
            
            Image(systemName: "arrowtriangle.down.fill")
                .font(.system(size: 12))
                .foregroundColor(isHighlighted ? Color.yellow : Color("AccentColor"))
                .offset(y: -5)
        }
    }
    
    private func iconForCategory(_ category: String) -> String {
        switch category {
        case "Coffee":
            return "cup.and.saucer.fill"
        case "Study":
            return "book.fill"
        case "Sports":
            return "sportscourt.fill"
        case "Food":
            return "fork.knife"
        case "Explore":
            return "binoculars.fill"
        case "Music":
            return "music.note"
        case "Art":
            return "paintpalette.fill"
        case "Tech":
            return "laptopcomputer"
        case "Outdoor":
            return "leaf.fill"
        case "Fitness":
            return "figure.walk"
        case "Games":
            return "gamecontroller.fill"
        case "Travel":
            return "airplane"
        case "Events":
            return "calendar.circle.fill"
        case "Fashion":
            return "tshirt.fill"
        case "Health":
            return "heart.fill"
        case "Books":
            return "books.vertical.fill"
        case "Movies":
            return "film.fill"
        default:
            return "star.fill"
        }
    }
}

struct HotspotAnnotationView: View {
    let hotspot: Hotspot
    let isSelected: Bool
    let zoomLevel: Double
    @State private var isAnimating = false
    
    var body: some View {
        Circle()
            .fill(Color("AccentColor").opacity(0.5))
            .frame(width: size, height: size)
            .overlay(
                Circle()
                    .stroke(Color("AccentColor"), lineWidth: 2)
            )
            .scaleEffect(isAnimating ? 1.1 : 1)
            .scaleEffect(isSelected ? 1.2 : 1)
            .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isAnimating)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
            .onAppear {
                isAnimating = true
            }
    }
    
    private var size: CGFloat {
        let baseSize = CGFloat(hotspot.activityCount * 3)
        let zoomFactor = 1 / zoomLevel
        return min(max(baseSize * zoomFactor, 20), 60) // Limit size between 20 and 60
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
            
            VStack(alignment: .leading, spacing: 8) {
                Text(activity.category)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color("AccentColor").opacity(0.2))
                    .foregroundColor(Color("AccentColor"))
                    .clipShape(Capsule())
                
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
                    Spacer()
                    Image(systemName: "person.2.fill")
                    Text("\(activity.currentParticipants)/\(activity.maxParticipants)")
                }
                .font(.caption)
                .foregroundColor(Color("AccentColor"))
            }
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

struct EmptyStateAnimation: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color("AccentColor").opacity(0.3), lineWidth: 5)
                .frame(width: 150, height: 150)
            
            Circle()
                .trim(from: 0, to: 0.3)
                .stroke(Color("AccentColor"), lineWidth: 5)
                .frame(width: 150, height: 150)
                .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
            
            Image(systemName: "mappin.and.ellipse")
                .font(.system(size: 50))
                .foregroundColor(Color("AccentColor"))
                .offset(y: isAnimating ? -10 : 10)
                .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isAnimating)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// Add this struct at the bottom of the file
struct HotspotNotificationView: View {
    let hotspot: Hotspot
    let isInside: Bool
    let onDismiss: () -> Void
    
    @State private var offset: CGFloat = 100
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: isInside ? "location.fill" : "location")
                    .foregroundColor(Color("AccentColor"))
                    .font(.system(size: 24))
                Text(isInside ? "You're in a Hotspot!" : "Approaching Hotspot")
                    .font(.headline)
                    .foregroundColor(Color("NeutralDark"))
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color("NeutralDark").opacity(0.6))
                        .font(.system(size: 24))
                }
            }
            
            Text("\(hotspot.activityCount) activities nearby")
                .font(.subheadline)
                .foregroundColor(Color("NeutralDark").opacity(0.8))
            
            Text(isInside ? "Explore what's happening around you!" : "Get ready to discover exciting activities!")
                .font(.caption)
                .foregroundColor(Color("NeutralDark").opacity(0.7))
            
            Button(action: {
                // Action to view hotspot details
            }) {
                Text("View Activities")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(Color("AccentColor"))
                    .cornerRadius(20)
            }
        }
        .padding()
        .background(Color("NeutralLight"))
        .cornerRadius(16)
        .shadow(color: Color("NeutralDark").opacity(0.1), radius: 10, x: 0, y: 5)
        .offset(y: offset)
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: offset)
        .onAppear {
            withAnimation {
                offset = 0
            }
        }
    }
}

struct HotspotDetailView: View {
    let hotspot: Hotspot
    let activities: [Activity]
    let onDismiss: () -> Void
    @Binding var selectedActivity: Activity?
    @Binding var showActivityDetail: Bool
    
    var body: some View {
        VStack {
            HStack {
                Text("Hotspot Activities")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color("NeutralDark").opacity(0.6))
                }
            }
            .padding()
            
            List(activities) { activity in
                ActivityRowView(activity: activity)
                    .onTapGesture {
                        selectedActivity = activity
                        showActivityDetail = true
                    }
            }
        }
        .background(Color("NeutralLight"))
        .cornerRadius(16)
        .shadow(color: Color("NeutralDark").opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

struct ActivityRowView: View {
    let activity: Activity
    
    var body: some View {
        HStack {
            Image(systemName: iconForCategory(activity.category))
                .foregroundColor(Color("AccentColor"))
                .frame(width: 30, height: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.title)
                    .font(.headline)
                Text(activity.description)
                    .font(.subheadline)
                    .foregroundColor(Color("NeutralDark").opacity(0.7))
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func iconForCategory(_ category: String) -> String {
        // Use the existing iconForCategory function from HomeView
        HomeView.iconForCategory(category)
    }
}