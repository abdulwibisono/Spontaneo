import SwiftUI
import MapKit

struct CreateActivityView: View {
    @Environment(\.presentationMode) var presentationMode
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
            Form {
                Section(header: Text("Basic Information")) {
                    TextField("Title", text: $title)
                        .padding(.vertical, 8)
                    
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding(.vertical, 8)
                    
                    TextEditor(text: $description)
                        .frame(height: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                        .padding(.vertical, 8)
                }
                
                Section(header: Text("Date and Time")) {
                    DatePicker("Date and Time", selection: $date, in: Date()...)
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .padding(.vertical, 8)
                }
                
                Section(header: Text("Location")) {
                    TextField("Location", text: $location)
                        .padding(.vertical, 8)
                    
                    Map(coordinateRegion: $region)
                        .frame(height: 200)
                        .cornerRadius(12)
                        .padding(.vertical, 8)
                }
                
                Section(header: Text("Participants")) {
                    Stepper("Max Participants: \(maxParticipants)", value: $maxParticipants, in: 2...100)
                        .padding(.vertical, 8)
                }
                
                Section(header: Text("Privacy")) {
                    Toggle("Public Activity", isOn: $isPublic)
                        .padding(.vertical, 8)
                }
                
                Section(header: Text("Image")) {
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        HStack {
                            Image(systemName: "photo")
                            Text("Select Image")
                        }
                    }
                    .padding(.vertical, 8)
                    
                    if let image = image {
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(12)
                            .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("Create Activity")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Create") {
                    createActivity()
                }
                .disabled(title.isEmpty || category.isEmpty || location.isEmpty)
            )
        }
        .accentColor(.blue)
        .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
            ImagePicker(image: $inputImage)
        }
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        image = Image(uiImage: inputImage)
    }
    
    func createActivity() {
        // Here you would typically save the activity to your data model or send it to a server
        // For now, we'll just print the details and dismiss the view
        print("Creating activity: \(title)")
        presentationMode.wrappedValue.dismiss()
    }
}

struct CreateActivityView_Previews: PreviewProvider {
    static var previews: some View {
        CreateActivityView()
    }
}
