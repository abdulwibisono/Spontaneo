import SwiftUI
import MapKit
import CoreLocation

struct CreateActivityView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var activityService = ActivityService()
    @EnvironmentObject var authService: AuthenticationService
    
    @State private var title = ""
    @State private var description = ""
    @State private var category = ""
    @State private var date = Date()
    @State private var location = ""
    @State private var maxParticipants = 10
    @State private var isPublic = true
    @State private var showingImagePicker = false
    @State private var inputImages: [UIImage] = [] // Store selected images
    @State private var imageUrls: [URL] = [] // Store uploaded image URLs
    @State private var image: Image?
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -27.4698, longitude: 153.0251),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    // Autocomplete Properties
    @StateObject private var searchCompleter = SearchCompleter()
    @FocusState private var isLocationFieldFocused: Bool
    
    let categories = [
        "Coffee", "Study", "Sports", "Food", "Explore", "Music", "Art", "Tech", 
        "Outdoor", "Fitness", "Games", "Travel", "Events", "Fashion", "Health", 
        "Books", "Movies"
    ]
    @State private var locationCoordinate: CLLocationCoordinate2D?
    @State private var isLocationValid: Bool = false
    
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
            .navigationTitle("Create Activity")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(Color("AccentColor")),
                trailing: Button("Create") {
                    createActivity()
                }
                .disabled(title.isEmpty || category.isEmpty || location.isEmpty)
                .foregroundColor(title.isEmpty || category.isEmpty || location.isEmpty ? Color("NeutralDark").opacity(0.4) : Color("AccentColor"))
            )
        }
        .accentColor(Color("AccentColor"))
        .edgesIgnoringSafeArea(.bottom)
        .sheet(isPresented: $showingImagePicker) {
            PhotoPicker(selectedImages: $inputImages)
        }
    }
    
    // MARK: - Sections
    
    private var imageSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Photos")
                .font(.headline)
                .foregroundColor(Color("NeutralDark"))
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(inputImages.indices, id: \.self) { index in
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: inputImages[index])
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipped()
                                .cornerRadius(8)
                            
                            Button(action: {
                                deleteImage(at: index)
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                                    .background(Color.white)
                                    .clipShape(Circle())
                            }
                            .padding(4)
                        }
                    }
                    
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        VStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 30))
                            Text("Add Photo")
                                .font(.caption)
                        }
                        .frame(width: 100, height: 100)
                        .background(Color("NeutralLight"))
                        .foregroundColor(Color("AccentColor"))
                        .cornerRadius(8)
                    }
                }
                .padding(.vertical, 8)
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
            Text("Category")
                .font(.headline)
                .foregroundColor(Color("NeutralDark"))
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(categories, id: \.self) { cat in
                        Button(action: {
                            category = cat
                        }) {
                            HStack {
                                Image(systemName: HomeView.iconForCategory(cat))
                                Text(cat)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(category == cat ? Color("AccentColor") : Color(.white))
                            .foregroundColor(category == cat ? Color("NeutralLight") : Color("NeutralDark"))
                            .cornerRadius(20)
                        }
                    }
                }
            }
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
            Map(coordinateRegion: .constant(region), annotationItems: selectedLocationAnnotation) { item in
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
        // This function will be called after image picker is dismissed
        // Implement logic to handle multiple images if needed
        // For example, you can update the UI to show the selected images
        if let newImage = inputImages.last {
            image = Image(uiImage: newImage)
        }
    }
    
    private func createActivity() {
        guard let currentUser = authService.user, isLocationValid, let coordinate = locationCoordinate else {
            print("Invalid location or user not logged in")
            return
        }

        uploadImages { urls in
            let newActivity = Activity(
                title: title,
                category: category,
                date: date,
                location: Activity.Location(
                    name: location,
                    latitude: coordinate.latitude,
                    longitude: coordinate.longitude
                ),
                currentParticipants: 1,
                maxParticipants: maxParticipants,
                hostId: currentUser.id,
                hostName: currentUser.username,
                hostRating: currentUser.averageRating,
                description: description,
                tags: [],
                receiveUpdates: true,
                updates: [],
                rating: 0.0,
                joinedUsers: [Activity.JoinedUser(id: currentUser.id, username: currentUser.username, fullName: currentUser.fullName)],
                imageUrls: urls
            )
            
            if let id = activityService.createActivity(newActivity) {
                print("Created activity with ID: \(id)")
                presentationMode.wrappedValue.dismiss()
            } else {
                print("Failed to create activity")
            }
        }
    }
    
    private func uploadImages(completion: @escaping ([URL]) -> Void) {
        activityService.uploadImages(inputImages) { urls in
            self.imageUrls = urls
            completion(urls)
        }
    }
    
    private func deleteImage(at index: Int) {
        inputImages.remove(at: index)
    }
}

class SearchCompleter: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var results: [MKLocalSearchCompletion] = []
    private let completer: MKLocalSearchCompleter

    override init() {
        completer = MKLocalSearchCompleter()
        super.init()
        completer.delegate = self
        completer.resultTypes = [.address, .pointOfInterest] // Add .address type
        
    }

    func search(query: String) {
        completer.queryFragment = query
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        DispatchQueue.main.async {
            self.results = completer.results
        }
    }

    func getLocation(for result: MKLocalSearchCompletion, completion: @escaping (CLLocation?) -> Void) {
        let searchRequest = MKLocalSearch.Request(completion: result)
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            guard let coordinate = response?.mapItems.first?.placemark.coordinate else {
                completion(nil)
                return
            }
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            completion(location)
        }
    }
}