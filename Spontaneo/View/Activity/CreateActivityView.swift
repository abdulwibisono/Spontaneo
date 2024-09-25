import SwiftUI
import MapKit

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
    @State private var inputImage: UIImage?
    @State private var image: Image?
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -27.4698, longitude: 153.0251),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    let categories = ["Coffee", "Study", "Sports", "Food", "Explore"]
    
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
                .padding(.bottom, 80) // Add extra padding at the bottom
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
        .edgesIgnoringSafeArea(.bottom) // Ignore safe area at the bottom
        .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
            ImagePicker(image: $inputImage)
        }
    }
    
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
            Map(coordinateRegion: $region)
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
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        image = Image(uiImage: inputImage)
    }
    
    private func createActivity() {
        guard let currentUser = authService.user else {
            print("No user logged in")
            return
        }

        let newActivity = Activity(
            title: title,
            category: category,
            date: date,
            location: Activity.Location(name: location, latitude: region.center.latitude, longitude: region.center.longitude),
            currentParticipants: 1,  // Assuming the creator is the first participant
            maxParticipants: maxParticipants,
            hostId: currentUser.id,
            hostName: currentUser.username,  // Use the current user's username
            description: description,
            tags: [],  // Add logic to handle tags
            receiveUpdates: true,
            updates: [],
            rating: 0.0  // Initial rating for new activities
        )
        
        if let id = activityService.createActivity(newActivity) {
            print("Created activity with ID: \(id)")
            presentationMode.wrappedValue.dismiss()
        } else {
            print("Failed to create activity")
        }
    }
}
