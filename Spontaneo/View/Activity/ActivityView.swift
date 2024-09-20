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
    
    @State private var activities = Activity.sampleActivities
    @State private var filters = ActivityFilters()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                headerSection
                
                if showMapView {
                    mapView
                } else {
                    listView
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
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search activities...", text: $searchText)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                Button(action: { showFilters.toggle() }) {
                    Image(systemName: "slider.horizontal.3")
                        .foregroundColor(.blue)
                }
            }
            .padding(8)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            HStack {
                Button(action: { showLocationPicker.toggle() }) {
                    HStack {
                        Image(systemName: "mappin.circle.fill")
                        Text(selectedLocation)
                    }
                }
                Spacer()
                Button(action: { showSortOptions.toggle() }) {
                    HStack {
                        Image(systemName: "arrow.up.arrow.down")
                        Text(sortOption.rawValue)
                    }
                }
                Button(action: { showMapView.toggle() }) {
                    Image(systemName: showMapView ? "list.bullet" : "map")
                }
            }
            .font(.subheadline)
            
            activeFiltersView
        }
        .padding()
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
    }
    
    private var activeFiltersView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                if filters.categories.isEmpty && filters.minRating == 0 && filters.maxDistance == 50 && filters.dateRange == nil {
                    Text("No filters applied")
                        .foregroundColor(.gray)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color(.systemGray6))
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
                ForEach(filteredActivities) { activity in
                    NavigationLink(destination: ActivityDetailedView(activity: activity)) {
                        ActivityCard(activity: activity)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
        }
        .refreshable {
            await refreshActivities()
        }
    }
    
    private var mapView: some View {
        Map {
            ForEach(filteredActivities) { activity in
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
            let ratingMatch = activity.host.rating >= filters.minRating
            let distanceMatch = true // You would need to calculate the distance based on user's location
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
}

struct FilterChip: View {
    let text: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack {
            Text(text)
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemGray6))
        .cornerRadius(20)
    }
}

struct ActivityCard: View {
    let activity: Activity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: "photo")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 150)
                .clipped()
                .cornerRadius(12)
            
            Text(activity.title)
                .font(.headline)
            
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text(String(format: "%.1f", activity.host.rating))
                Text("(\(Int.random(in: 10...100)) reviews)")
                    .foregroundColor(.secondary)
            }
            
            Text(activity.description)
                .lineLimit(2)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Image(systemName: "mappin.circle.fill")
                Text(activity.location.name)
                Spacer()
                Text(activity.date, style: .time)
            }
            .font(.caption)
            
            HStack {
                Text("\(activity.currentParticipants)/\(activity.maxParticipants) participants")
                Spacer()
                Button("Join") {
                    // Join action
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
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
                                    .foregroundColor(.blue)
                                Text(category)
                                Spacer()
                                if filters.categories.contains(category) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                } else {
                                    Image(systemName: "circle")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }
                
                Section(header: Text("Minimum Rating")) {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Slider(value: $filters.minRating, in: 0...5, step: 0.5)
                        Text(String(format: "%.1f", filters.minRating))
                            .frame(width: 35)
                    }
                }
                
                Section(header: Text("Maximum Distance")) {
                    Picker(selection: $filters.maxDistance, label: 
                        HStack {
                            Image(systemName: "location.circle")
                                .foregroundColor(.blue)
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
                                    .foregroundColor(.blue)
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
                                    .foregroundColor(.blue)
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
