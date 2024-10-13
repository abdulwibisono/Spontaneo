import SwiftUI
import MapKit
import CoreLocation
import SDWebImageSwiftUI // Add this import for image caching

struct ActivityView: View {
    @State private var searchText = ""
    @State private var showFilters = false
    @State private var showMapView = false
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -27.4698, longitude: 153.0251),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @State private var selectedLocation = "Brisbane"
    @State private var sortOption: SortOption = .relevance
    @State private var isLoading = false
    @State private var showLocationPicker = false
    @State private var showSortOptions = false
    
    @StateObject private var activityService = ActivityService()
    @EnvironmentObject var authService: AuthenticationService
    @State private var activities: [Activity] = []
    @State private var filters = ActivityFilters()
    
    @State private var showingCreateActivity = false
    @State private var scrollOffset: CGFloat = 0
    
    @State private var debouncedSearchText = ""
    @State private var searchTask: Task<Void, Never>?
    
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundColor").edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    headerSection
                    
                    if showMapView {
                        mapView
                    } else {
                        ScrollView {
                            GeometryReader { geometry in
                                Color.clear.preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .named("scroll")).origin.y)
                            }
                            .frame(height: 0)
                            
                            VStack(spacing: 16) {
                                if !debouncedSearchText.isEmpty && filteredActivities.isEmpty {
                                    Text("No activities found for '\(debouncedSearchText)'")
                                        .foregroundColor(Color("NeutralDark"))
                                        .padding()
                                } else {
                                    featuredActivitiesSection
                                    listView
                                }
                            }
                            .padding(.bottom, 80)
                        }
                        .coordinateSpace(name: "scroll")
                        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                            scrollOffset = value
                        }
                        .refreshable {
                            await refreshActivities()
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showFilters) {
                FilterView(currentFilters: filters, applyFilters: applyFilters)
            }
            .sheet(isPresented: $showLocationPicker) {
                LocationPickerView(selectedLocation: $selectedLocation)
            }
            .actionSheet(isPresented: $showSortOptions) {
                ActionSheet(title: Text("Sort Activities"), buttons: sortButtons)
            }
            .overlay(loadingOverlay)
            .overlay(createActivityButton, alignment: .bottomTrailing)
        }
        .accentColor(Color("AccentColor"))
        .sheet(isPresented: $showingCreateActivity) {
            CreateActivityView().environmentObject(authService)
        }
        .edgesIgnoringSafeArea(.bottom)
        .onAppear {
            fetchActivities()
        }
        .onChange(of: searchText) { newValue in
            searchTask?.cancel()
            searchTask = Task {
                try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds debounce
                if !Task.isCancelled {
                    await MainActor.run {
                        debouncedSearchText = newValue
                    }
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color("NeutralDark"))
                TextField("Search activities...", text: $searchText)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                Button(action: { showFilters.toggle() }) {
                    Image(systemName: "slider.horizontal.3")
                        .foregroundColor(Color("AccentColor"))
                }
            }
            .padding(12)
            .background(Color("NeutralLight"))
            .cornerRadius(15)
            .shadow(color: Color("NeutralDark").opacity(0.1), radius: 5, x: 0, y: 2)
            
            HStack {
                Button(action: { showLocationPicker.toggle() }) {
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                        Text(selectedLocation)
                    }
                    .foregroundColor(Color("AccentColor"))
                }
                Spacer()
                Button(action: { showSortOptions.toggle() }) {
                    HStack {
                        Image(systemName: "arrow.up.arrow.down.circle")
                        Text(sortOption.rawValue)
                    }
                    .foregroundColor(Color("AccentColor"))
                }
                Button(action: { showMapView.toggle() }) {
                    Image(systemName: showMapView ? "list.bullet.circle" : "map.circle")
                        .foregroundColor(Color("AccentColor"))
                }
            }
            .font(.subheadline)
            
            activeFiltersView
            
            if !filters.isEmpty {
                Button(action: clearAllFilters) {
                    Text("Clear all filters")
                        .font(.subheadline)
                        .foregroundColor(Color("AccentColor"))
                }
            }
        }
        .padding()
        .background(Color("NeutralLight"))
        .shadow(color: Color("NeutralDark").opacity(0.1), radius: 10, x: 0, y: 5)
        .opacity(1 - min(1, max(0, -scrollOffset / 100)))
    }
    
    private var featuredActivitiesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Featured Activities")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(filteredActivities.prefix(5)) { activity in
                        FeaturedActivityCard(activity: activity)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.top)
    }
    
    private var listView: some View {
        LazyVStack(spacing: 16) {
            ForEach(filteredActivities) { activity in
                NavigationLink(destination: ActivityDetailedView(activity: activity, activityService: activityService)) {
                    ActivityCard(activity: activity, activityService: activityService)
                        .transition(.opacity)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal)
    }
    
    private func fetchActivities() {
        activityService.getAllActivities { fetchedActivities in
            self.activities = fetchedActivities
        }
    }
    
    private var activeFiltersView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                if filters.categories.isEmpty && filters.minRating == 0 && filters.maxDistance == 50 && filters.dateRange == nil {
                    Text("No filters applied")
                        .foregroundColor(Color("NeutralDark"))
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color("NeutralLight"))
                        .cornerRadius(20)
                } else {
                    ForEach(Array(filters.categories), id: \.self) { category in
                        FilterChip(text: category, onRemove: { removeCategory(category) })
                    }
                    if filters.minRating > 0 {
                        FilterChip(text: "Rating: \(String(format: "%.1f", filters.minRating))+", onRemove: { filters.minRating = 0 })
                    }
                    if filters.maxDistance < 50 {
                        FilterChip(text: "Within \(Int(filters.maxDistance))km", onRemove: { filters.maxDistance = 50 })
                    }
                    if let dateRange = filters.dateRange {
                        FilterChip(text: formatDateRange(dateRange), onRemove: { filters.dateRange = nil })
                    }
                }
            }
        }
    }
    
    private func removeCategory(_ category: String) {
        filters.categories.remove(category)
    }
    
    private func formatDateRange(_ range: ClosedRange<Date>) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return "\(formatter.string(from: range.lowerBound)) - \(formatter.string(from: range.upperBound))"
    }
    
    private var mapView: some View {
        Map {
            ForEach(filteredActivities) { activity in
                Annotation(activity.title, coordinate: activity.location.coordinate) {
                    ActivityMapPin(activity: activity, activityService: activityService)
                }
            }
        }
        .mapStyle(.standard)
    }
    
    private var filteredActivities: [Activity] {
        activities.filter { activity in
            let searchMatch = debouncedSearchText.isEmpty || activity.title.lowercased().contains(debouncedSearchText.lowercased()) || activity.description.lowercased().contains(debouncedSearchText.lowercased())
            let categoryMatch = filters.categories.isEmpty || filters.categories.contains(activity.category)
            let ratingMatch = activity.rating >= filters.minRating
            let distanceMatch = calculateDistance(to: activity.location) <= filters.maxDistance
            let dateMatch = filters.dateRange.map { $0.contains(activity.date) } ?? true
            
            return searchMatch && categoryMatch && ratingMatch && distanceMatch && dateMatch
        }
        .sorted(by: sortOption.sortingClosure)
    }
    
    private func calculateDistance(to location: Activity.Location) -> Double {
        guard let userLocation = locationManager.location else {
            return Double.infinity // Return a large value if user location is not available
        }
        
        let activityLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        let distanceInMeters = userLocation.distance(from: activityLocation)
        return distanceInMeters / 1000 // Convert to kilometers
    }
    
    private var loadingOverlay: some View {
        Group {
            if isLoading {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .overlay(
                        ProgressView()
                            .scaleEffect(1.5)
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    )
            }
        }
    }
    
    private var sortButtons: [ActionSheet.Button] {
        SortOption.allCases.map { option in
            .default(Text(option.rawValue)) {
                sortOption = option
            }
        } + [.cancel()]
    }
    
    private func applyFilters(_ newFilters: ActivityFilters) {
        filters = newFilters
        // Here you would typically make an API call with the new filters
        // For now, we'll just update the filtered activities
        // activities = fetchFilteredActivities(filters: filters)
    }
    
    private func refreshActivities() async {
        isLoading = true
        // Simulate network request
        try? await Task.sleep(nanoseconds: 2 * 1_000_000_000) // 2 seconds
        // Refresh activities here
        isLoading = false
    }
    
    private var createActivityButton: some View {
        Button(action: {
            showingCreateActivity = true
        }) {
            Image(systemName: "plus")
                .font(.title2)
                .foregroundColor(Color("NeutralLight"))
                .frame(width: 60, height: 60)
                .background(
                    LinearGradient(gradient: Gradient(colors: [Color("AccentColor"), Color("SecondaryColor")]), startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .clipShape(Circle())
                .shadow(color: Color("NeutralDark").opacity(0.3), radius: 5, x: 0, y: 2)
        }
        .padding(.trailing, 20)
        .padding(.bottom, 100)
    }
    
    private func clearAllFilters() {
        filters = ActivityFilters()
        debouncedSearchText = ""
        searchText = ""
    }
    
    // Add this computed property to check if any filters are active
    private var filtersActive: Bool {
        return !filters.categories.isEmpty || filters.minRating > 0 || filters.maxDistance < 50 || filters.dateRange != nil || !debouncedSearchText.isEmpty
    }
}

struct ActivityFilters {
    var categories: Set<String> = []
    var minRating: Double = 0
    var maxDistance: Double = 50 // km
    var dateRange: ClosedRange<Date>?
    
    var isEmpty: Bool {
        return categories.isEmpty && minRating == 0 && maxDistance == 50 && dateRange == nil
    }
}

struct FilterChip: View {
    let text: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack {
            Text(text)
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(Color("NeutralDark"))
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color("NeutralLight"))
        .foregroundColor(Color("NeutralDark"))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color("AccentColor"), lineWidth: 1)
        )
    }
}

struct ActivityCard: View {
    let activity: Activity
    @ObservedObject var activityService: ActivityService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .topTrailing) {
                if let firstImageUrl = activity.imageUrls.first {
                    AsyncImage(url: firstImageUrl) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 150)
                            .clipped()
                            .cornerRadius(12)
                    } placeholder: {
                        ProgressView()
                    }
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 150)
                        .clipped()
                        .cornerRadius(12)
                }
                
                Text(activity.category)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color("AccentColor"))
                    .foregroundColor(Color("NeutralLight"))
                    .cornerRadius(8)
                    .padding(8)
            }
            
            Text(activity.title)
                .font(.headline)
                .foregroundColor(Color("NeutralDark"))
            
            HStack {
                Image(systemName: "person.circle.fill")
                    .foregroundColor(Color("AccentColor"))
                Text(activity.hostName)
                    .font(.subheadline)
                    .foregroundColor(Color("NeutralDark"))
                Spacer()
                Image(systemName: "star.fill")
                    .foregroundColor(Color("SecondaryColor"))
                Text(String(format: "%.1f", activity.rating))
                    .font(.subheadline)
                    .foregroundColor(Color("NeutralDark"))
            }
            
            Text(activity.description)
                .lineLimit(2)
                .font(.subheadline)
                .foregroundColor(Color("NeutralDark").opacity(0.8))
            
            HStack {
                Image(systemName: "mappin.circle.fill")
                Text(activity.location.name)
                Spacer()
                Image(systemName: "clock")
                Text(activity.date, style: .time)
            }
            .font(.caption)
            .foregroundColor(Color("NeutralDark").opacity(0.7))
            
            HStack {
                HStack(spacing: -8) {
                    ForEach(0..<min(3, activity.currentParticipants), id: \.self) { _ in
                        Image(systemName: "person.circle.fill")
                            .font(.title2)
                            .foregroundColor(Color("AccentColor"))
                    }
                }
                Text("\(activity.currentParticipants)/\(activity.maxParticipants)")
                    .font(.caption)
                    .foregroundColor(Color("NeutralDark"))
                Spacer()
                if let currentUser = authService.user, activity.hostId != currentUser.id {
                    Button(action: {
                        if isJoined {
                            leaveActivity()
                        } else {
                            joinActivity()
                        }
                    }) {
                        Text(isJoined ? "Leave" : "Join")
                            .fontWeight(.semibold)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                LinearGradient(gradient: Gradient(colors: [Color("AccentColor"), Color("SecondaryColor")]), startPoint: .leading, endPoint: .trailing)
                            )
                            .foregroundColor(Color("NeutralLight"))
                            .cornerRadius(20)
                    }
                }
            }
            
            if activity.hostId == authService.user?.id {
                Button(action: {
                    showingEditActivity = true
                }) {
                    Image(systemName: "pencil")
                        .foregroundColor(Color("AccentColor"))
                }
                .sheet(isPresented: $showingEditActivity) {
                    EditActivityView(activity: activity)
                }
            }
        }
        .padding()
        .background(Color("NeutralLight"))
        .cornerRadius(16)
        .shadow(color: Color("NeutralDark").opacity(0.1), radius: 10, x: 0, y: 5)
        .onAppear {
            checkIfUserJoined()
        }
    }
    
    @State private var showingEditActivity = false
    @State private var isJoined = false
    @EnvironmentObject var authService: AuthenticationService
    
    private func checkIfUserJoined() {
        if let currentUser = authService.user {
            isJoined = activity.joinedUsers.contains { $0.id == currentUser.id }
        }
    }
    
    private func joinActivity() {
        guard let currentUser = authService.user else { return }
        
        Task {
            do {
                try await activityService.joinActivity(activityId: activity.id!, user: currentUser)
                await MainActor.run {
                    isJoined = true
                }
            } catch {
                print("Error joining activity: \(error.localizedDescription)")
            }
        }
    }
    
    private func leaveActivity() {
        guard let currentUser = authService.user else { return }
        
        Task {
            do {
                try await activityService.leaveActivity(activityId: activity.id!, userId: currentUser.id)
                await MainActor.run {
                    isJoined = false
                }
            } catch {
                print("Error leaving activity: \(error.localizedDescription)")
            }
        }
    }
}

struct ActivityMapPin: View {
    let activity: Activity
    @ObservedObject var activityService: ActivityService
    @State private var showDetails = false
    
    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: "mappin.circle.fill")
                .font(.title)
                .foregroundColor(.red)
            
            Text(activity.title)
                .font(.caption)
                .padding(4)
                .background(Color.white)
                .cornerRadius(4)
                .offset(y: -5)
        }
        .onTapGesture {
            showDetails.toggle()
        }
        .sheet(isPresented: $showDetails) {
            ActivityDetailedView(activity: activity, activityService: activityService)
        }
    }
}

enum SortOption: String, CaseIterable {
    case relevance = "Relevance"
    case dateAscending = "Date: Earliest First"
    case dateDescending = "Date: Latest First"
    case popularityDescending = "Most Popular"
    
    var sortingClosure: (Activity, Activity) -> Bool {
        switch self {
        case .relevance:
            return { _, _ in true } // No specific sorting
        case .dateAscending:
            return { $0.date < $1.date }
        case .dateDescending:
            return { $0.date > $1.date }
        case .popularityDescending:
            return { $0.currentParticipants > $1.currentParticipants }
        }
    }
}

struct FilterView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var filters: ActivityFilters
    var applyFilters: (ActivityFilters) -> Void
    
    let allCategories = [
        "Coffee", "Study", "Sports", "Food", "Explore", "Music", "Art", "Tech", 
        "Outdoor", "Fitness", "Games", "Travel", "Events", "Fashion", "Health", 
        "Books", "Movies"
    ]
    let distanceOptions = [5.0, 10.0, 20.0, 50.0]
    
    init(currentFilters: ActivityFilters, applyFilters: @escaping (ActivityFilters) -> Void) {
        _filters = State(initialValue: currentFilters)
        self.applyFilters = applyFilters
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Categories")) {
                    ForEach(allCategories, id: \.self) { category in
                        Button(action: {
                            if filters.categories.contains(category) {
                                filters.categories.remove(category)
                            } else {
                                filters.categories.insert(category)
                            }
                        }) {
                            HStack {
                                Image(systemName: categoryIcon(for: category))
                                    .foregroundColor(Color("AccentColor"))
                                Text(category)
                                Spacer()
                                if filters.categories.contains(category) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(Color("AccentColor"))
                                } else {
                                    Image(systemName: "circle")
                                        .foregroundColor(Color("NeutralDark"))
                                }
                            }
                        }
                    }
                }
                
                Section(header: Text("Minimum Rating")) {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(Color("SecondaryColor"))
                        Slider(value: $filters.minRating, in: 0...5, step: 0.5)
                            .accentColor(Color("AccentColor"))
                        Text(String(format: "%.1f", filters.minRating))
                            .frame(width: 35)
                    }
                }
                
                Section(header: Text("Maximum Distance")) {
                    Picker(selection: $filters.maxDistance, label: 
                        HStack {
                            Image(systemName: "location.circle")
                                .foregroundColor(Color("AccentColor"))
                            Text("Distance")
                        }
                    ) {
                        ForEach(distanceOptions, id: \.self) { distance in
                            Text("\(Int(distance)) km").tag(distance)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Date Range")) {
                    DatePicker(
                        selection: Binding(
                            get: { filters.dateRange?.lowerBound ?? Date() },
                            set: { filters.dateRange = $0...($0.addingTimeInterval(86400)) }
                        ),
                        displayedComponents: .date,
                        label: {
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(Color("AccentColor"))
                                Text("Start Date")
                            }
                        }
                    )
                    
                    DatePicker(
                        selection: Binding(
                            get: { filters.dateRange?.upperBound ?? Date().addingTimeInterval(86400) },
                            set: { if let start = filters.dateRange?.lowerBound { filters.dateRange = start...$0 } }
                        ),
                        displayedComponents: .date,
                        label: {
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(Color("AccentColor"))
                                Text("End Date")
                            }
                        }
                    )
                }
            }
            .navigationTitle("Filters")
            .navigationBarItems(
                leading: Button(action: resetFilters) {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Reset")
                    }
                },
                trailing: Button(action: {
                    applyFilters(filters)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "checkmark")
                        Text("Apply")
                    }
                }
            )
        }
    }
    
    private func resetFilters() {
        filters = ActivityFilters()
    }
    
    private func categoryIcon(for category: String) -> String {
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

struct LocationPickerView: View {
    @Binding var selectedLocation: String
    @Environment(\.presentationMode) var presentationMode
    
    let locations = ["Brisbane", "Sydney", "Melbourne", "Perth", "Adelaide"]
    
    var body: some View {
        NavigationView {
            List(locations, id: \.self) { location in
                Button(action: {
                    selectedLocation = location
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text(location)
                }
            }
            .navigationTitle("Select Location")
        }
    }
}

struct FeaturedActivityCard: View {
    let activity: Activity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                if let firstImageUrl = activity.imageUrls.first {
                    WebImage(url: firstImageUrl) // Use WebImage for caching
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 200, height: 120)
                        .clipped()
                        .cornerRadius(12)
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 200, height: 120)
                        .clipped()
                        .cornerRadius(12)
                }
                
                Text(activity.category)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color("AccentColor"))
                    .foregroundColor(Color("NeutralLight"))
                    .cornerRadius(8)
                    .padding(8)
            }
            
            Text(activity.title)
                .font(.headline)
                .lineLimit(1)
            
            HStack {
                Image(systemName: "person.circle.fill")
                    .foregroundColor(Color("AccentColor"))
                Text(activity.hostName)
                    .font(.subheadline)
                Spacer()
                Image(systemName: "star.fill")
                    .foregroundColor(Color("SecondaryColor"))
                Text(String(format: "%.1f", activity.rating))
                    .font(.subheadline)
            }
        }
        .frame(width: 200)
        .padding()
        .background(Color("NeutralLight"))
        .cornerRadius(16)
        .shadow(color: Color("NeutralDark").opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct ActivityView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityView()
    }
}