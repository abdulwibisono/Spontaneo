import SwiftUI

struct EditProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var fullName: String
    @State private var bio: String
    @State private var newInterest: String = ""
    
    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        _fullName = State(initialValue: viewModel.user.fullName)
        _bio = State(initialValue: viewModel.user.bio)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Profile Picture")) {
                    profileImagePicker
                }
                
                Section(header: Text("Personal Information")) {
                    TextField("Full Name", text: $fullName)
                    TextEditor(text: $bio)
                        .frame(height: 100)
                }
                
                Section(header: Text("Interests")) {
                    ForEach(viewModel.user.interests, id: \.self) { interest in
                        Text(interest)
                    }
                    .onDelete(perform: deleteInterest)
                    
                    HStack {
                        TextField("Add new interest", text: $newInterest)
                        Button(action: addInterest) {
                            Image(systemName: "plus.circle.fill")
                        }
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarItems(leading: cancelButton, trailing: saveButton)
        }
        .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
            ImagePicker(image: $inputImage)
        }
    }
    
    private var profileImagePicker: some View {
        HStack {
            Spacer()
            AsyncImage(url: viewModel.user.profileImageURL) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .foregroundColor(.gray)
            }
            .frame(width: 100, height: 100)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.blue, lineWidth: 2))
            .onTapGesture {
                showingImagePicker = true
            }
            Spacer()
        }
    }
    
    private var cancelButton: some View {
        Button("Cancel") {
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private var saveButton: some View {
        Button("Save") {
            viewModel.updateProfile(fullName: fullName, bio: bio)
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func addInterest() {
        let trimmedInterest = newInterest.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedInterest.isEmpty {
            viewModel.addInterest(trimmedInterest)
            newInterest = ""
        }
    }
    
    private func deleteInterest(at offsets: IndexSet) {
        viewModel.removeInterests(at: offsets)
    }
    
    private func loadImage() {
        guard let inputImage = inputImage else { return }
        viewModel.updateProfileImage(inputImage)
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            picker.dismiss(animated: true)
        }
    }
}

