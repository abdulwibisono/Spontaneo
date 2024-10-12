import SwiftUI
import MapKit
import CoreLocation

struct EditActivityView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var activityService = ActivityService()
    @State private var activity: Activity
    
    @State private var title: String
    @State private var description: String
    @State private var category: String
    @State private var date: Date
    @State private var location: String
    @State private var maxParticipants: Int
    @State private var isPublic: Bool
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var image: Image?
    
    @State private var region: MKCoordinateRegion
    
    // Autocomplete Properties
    @StateObject private var searchCompleter = SearchCompleter()
    @FocusState private var isLocationFieldFocused: Bool
    
    let categories = ["Coffee", "Study", "Sports", "Food", "Explore"]
    @State private var locationCoordinate: CLLocationCoordinate2D?
    @State private var isLocationValid: Bool = true
    
    init(activity: Activity) {
        _activity = State(initialValue: activity)
        _title = State(initialValue: activity.title)
        _description = State(initialValue: activity.description)
        _category = State(initialValue: activity.category)
        _date = State(initialValue: activity.date)
        _location = State(initialValue: activity.location.name)
        _maxParticipants = State(initialValue: activity.maxParticipants)
        _isPublic = State(initialValue: true) // Assuming all activities are public by default
        _region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: activity.location.latitude, longitude: activity.location.longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))
        _locationCoordinate = State(initialValue: CLLocationCoordinate2D(latitude: activity.location.latitude, longitude: activity.location.longitude))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    imageSection
                    
                    VStack(alignment: .leading, spacing: 24) {
                        titleSection
                        categorySection
                        descriptionSection
                        dateSection
                        locationSection
                        detailsSection
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 20)
                .padding(.bottom, 80) // Extra padding at the bottom
            }
            .background(Color("NeutralLight"))
            .navigationTitle("Edit Activity")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(Color("AccentColor")),
                trailing: Button("Save") {
                    saveActivity()
                }
                .disabled(title.isEmpty || category.isEmpty || location.isEmpty || !isLocationValid)
                .foregroundColor(title.isEmpty || category.isEmpty || location.isEmpty || !isLocationValid ? Color("NeutralDark").opacity(0.4) : Color("AccentColor"))
            )
        }
        .accentColor(Color("AccentColor"))
        .edgesIgnoringSafeArea(.bottom)
        .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
            ImagePicker(image: $inputImage)
        }
    }
    
    // MARK: - Sections
    
    private var imageSection: some View {
        ZStack {
            if let image = image {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(16)
            } else {
                Rectangle()
                    .fill(Color("NeutralLight"))
                    .frame(height: 200)
                    .cornerRadius(16)
                    .overlay(
                        VStack {
                            Image(systemName: "camera.fill")
                                .foregroundColor(Color("NeutralDark").opacity(0.4))
                                .font(.largeTitle)
                            Text("Add Photo")
                                .foregroundColor(Color("NeutralDark").opacity(0.4))
                                .font(.headline)
                        }
                    )
            }
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(Color("NeutralLight"))
                            .background(Color("AccentColor"))
                            .clipShape(Circle())
                            .shadow(color: Color("NeutralDark").opacity(0.3), radius: 5, x: 0, y: 2)
                    }
                    .padding()
                }
            }
        }
    }
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Title", systemImage: "pencil")
                .font(.headline)
                .foregroundColor(Color("NeutralDark"))
            TextField("Enter activity title", text: $title)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .foregroundColor(Color("NeutralDark"))
        }
    }
    
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Category", systemImage: "tag")
                .font(.headline)
                .foregroundColor(Color("NeutralDark"))
            Picker("Category", selection: $category) {
                ForEach(categories, id: \.self) { category in
                    Text(category).tag(category)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .background(Color("NeutralLight"))
        }
    }
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Description", systemImage: "text.alignleft")
                .font(.headline)
                .foregroundColor(Color("NeutralDark"))
            TextEditor(text: $description)
                .frame(height: 100)
                .foregroundColor(Color("NeutralDark"))
                .background(Color("NeutralLight"))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color("NeutralDark").opacity(0.1), lineWidth: 1)
                )
        }
    }
    
    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Date and Time", systemImage: "calendar")
                .font(.headline)
                .foregroundColor(Color("NeutralDark"))
            DatePicker("", selection: $date, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                .datePickerStyle(GraphicalDatePickerStyle())
                .accentColor(Color("AccentColor"))
        }
    }
    
    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Location", systemImage: "mappin.and.ellipse")
                .font(.headline)
                .foregroundColor(Color("NeutralDark"))
            TextField("Enter location", text: $location)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .foregroundColor(Color("NeutralDark"))
                .focused($isLocationFieldFocused)
                .onChange(of: location) { newValue in
                    searchCompleter.search(query: newValue)
                }
            if !isLocationValid && !location.isEmpty {
                Text("Invalid location. Please enter a valid address.")
                    .foregroundColor(.red)
                    .font(.caption)
            }
            if !searchCompleter.results.isEmpty && isLocationFieldFocused {
                List(searchCompleter.results, id: \.self) { result in
                    Button(action: {
                        selectLocation(result)
                    }) {
                        VStack(alignment: .leading) {
                            Text(result.title)
                            Text(result.subtitle)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .frame(height: min(CGFloat(searchCompleter.results.count * 44), 200))
            }
            Map(coordinateRegion: $region, annotationItems: selectedLocationAnnotation) { item in
                MapMarker(coordinate: item.coordinate)
            }
            .frame(height: 200)
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color("NeutralLight"), lineWidth: 1))
            .shadow(color: Color("NeutralDark").opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
    
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Label("Max Participants", systemImage: "person.3")
                    .font(.headline)
                    .foregroundColor(Color("NeutralDark"))
                Stepper("Max Participants: \(maxParticipants)", value: $maxParticipants, in: 2...100)
                    .foregroundColor(Color("NeutralDark"))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Label("Visibility", systemImage: "eye")
                    .font(.headline)
                    .foregroundColor(Color("NeutralDark"))
                Toggle("Public Activity", isOn: $isPublic)
                    .toggleStyle(SwitchToggleStyle(tint: Color("AccentColor")))
            }
        }
    }
    
    // MARK: - Helpers
    
    private var selectedLocationAnnotation: [SelectableLocation] {
        if location.isEmpty {
            return []
        }
        return [SelectableLocation(coordinate: region.center, name: location)]
    }
    
    private func selectLocation(_ result: MKLocalSearchCompletion) {
        searchCompleter.getLocation(for: result) { location in
            if let location = location {
                DispatchQueue.main.async {
                    self.location = result.title + ", " + result.subtitle
                    self.region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
                    self.isLocationValid = true
                    self.locationCoordinate = location.coordinate
                    self.isLocationFieldFocused = false
                }
            }
        }
    }
    
    private func loadImage() {
        guard let inputImage = inputImage else { return }
        image = Image(uiImage: inputImage)
    }
    
    private func saveActivity() {
        guard isLocationValid, let coordinate = locationCoordinate else {
            print("Invalid location")
            return
        }

        let updatedActivity = Activity(
            id: activity.id,
            title: title,
            category: category,
            date: date,
            location: Activity.Location(
                name: location,
                latitude: coordinate.latitude,
                longitude: coordinate.longitude
            ),
            currentParticipants: activity.currentParticipants,
            maxParticipants: maxParticipants,
            hostId: activity.hostId,
            hostName: activity.hostName,
            description: description,
            tags: activity.tags,
            receiveUpdates: activity.receiveUpdates,
            updates: activity.updates,
            rating: activity.rating,
            joinedUsers: activity.joinedUsers
        )
        
        activityService.updateActivity(updatedActivity) { result in
            switch result {
            case .success:
                presentationMode.wrappedValue.dismiss()
            case .failure(let error):
                print("Error updating activity: \(error.localizedDescription)")
            }
        }
    }
}

// Add the SearchCompleter class here if it's not already in a separate file
// class SearchCompleter: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
//     // ... (same as in CreateActivityView)
// }