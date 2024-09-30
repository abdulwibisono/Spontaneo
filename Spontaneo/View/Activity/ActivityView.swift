import SwiftUI
import MapKit

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
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("NeutralLight").edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    headerSection
                    
                    if showMapView {
                        mapView
                    } else {
                        listView
                            .padding(.bottom, 80) // Add padding at the bottom for TabView
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
        .edgesIgnoringSafeArea(.bottom) // Ignore safe area at the bottom
        .onAppear {
                    fetchActivities()
                }
    }
    
    private func fetchActivities() {
        activityService.getAllActivities { fetchedActivities in
            self.activities = fetchedActivities
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color("NeutralDark"))
                TextField("Search activities...", text: $searchText)
                    .autocapitalization(.none)
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
        }
        .padding()
        .background(Color("NeutralLight"))
        .shadow(color: Color("NeutralDark").opacity(0.1), radius: 10, x: 0, y: 5)
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
    
    private var listView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(activities) { activity in
                    NavigationLink(destination: ActivityDetailedView(activity: activity)) {
                        ActivityCardHome(activity: activity)
                    }
                }
            }
            .padding()
        }
    }
    
    private var mapView: some View {
        Map {
            ForEach(activities) { activity in
                Annotation(activity.title, coordinate: activity.location.coordinate) {
                    ActivityMapPin(activity: activity)
                }
            }
        }
        .mapStyle(.standard)
    }
    
    private var filteredActivities: [Activity] {
        activities.filter { activity in
            let categoryMatch = filters.categories.isEmpty || filters.categories.contains(activity.category)
            let ratingMatch = activity.rating >= filters.minRating
            let distanceMatch = true
            let dateMatch = filters.dateRange.map { $0.contains(activity.date) } ?? true
            
            return categoryMatch && ratingMatch && distanceMatch && dateMatch
        }
        .sorted(by: sortOption.sortingClosure)
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
    @State private var showingEditActivity = false
    @EnvironmentObject var authService: AuthenticationService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "photo")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 150)
                    .clipped()
                    .cornerRadius(12)
                
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
                Button(action: {}) {
                    Text("Join")
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
    }
}

struct ActivityMapPin: View {
    let activity: Activity
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
            ActivityDetailedView(activity: activity)
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

struct ActivityFilters {
    var categories: Set<String> = []
    var minRating: Double = 0
    var maxDistance: Double = 50 // km
    var dateRange: ClosedRange<Date>?
}

struct FilterView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var filters: ActivityFilters
    var applyFilters: (ActivityFilters) -> Void
    
    let allCategories = ["Coffee", "Study", "Sports", "Food", "Explore"]
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
        default:
            return "questionmark.circle"
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

struct ActivityView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityView()
    }
}