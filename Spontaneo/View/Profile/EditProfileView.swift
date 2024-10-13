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
            ZStack {
                Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 24) {
                        profileImagePicker
                        personalInfoSection
                        interestsSection
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 24)
                }
            }
            .navigationBarTitle("Edit Profile", displayMode: .inline)
            .navigationBarItems(leading: cancelButton, trailing: saveButton)
        }
        .accentColor(.blue)
        .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
            ImagePicker(image: $inputImage)
        }
    }
    
    private var profileImagePicker: some View {
        VStack {
            ZStack {
                if let image = viewModel.profileImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else if let url = viewModel.user.profileImageURL {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        ProgressView()
                    }
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .foregroundColor(.gray)
                }
            }
            .frame(width: 120, height: 120)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.blue, lineWidth: 2))
            .shadow(radius: 5)
            
            HStack {
                Button(action: {
                    showingImagePicker = true
                }) {
                    Text("Change Photo")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                .padding(.top, 8)
                
                Button(action: {
                    viewModel.deleteProfileImage()
                }) {
                    Text("Delete Photo")
                        .font(.headline)
                        .foregroundColor(.red)
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var personalInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Personal Information")
            
            CustomTextField(placeholder: "Full Name", text: $fullName, icon: "person.fill")
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Bio")
                    .font(.headline)
                    .foregroundColor(.primary)
                   
                TextEditor(text: $bio)
                    .frame(height: 100)
                    .padding(8)
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.blue.opacity(0.5), lineWidth: 1)
                    )
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var interestsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Interests")
            
            FlowLayout(alignment: .leading, spacing: 8) {
                ForEach(viewModel.user.interests, id: \.self) { interest in
                    InterestTag(interest: interest) {
                        viewModel.user.interests.removeAll { $0 == interest }
                    }
                }
            }
            
            HStack {
                CustomTextField(placeholder: "Add new interest", text: $newInterest, icon: "plus.circle.fill")
                
                Button(action: addInterest) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.white)
                        .imageScale(.large)
                        .frame(width: 44, height: 44)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var cancelButton: some View {
        Button("Cancel") {
            presentationMode.wrappedValue.dismiss()
        }
        .foregroundColor(.red)
    }
    
    private var saveButton: some View {
        Button("Save") {
            viewModel.updateProfile(fullName: fullName, bio: bio)
            presentationMode.wrappedValue.dismiss()
        }
        .fontWeight(.bold)
    }
    
    private func addInterest() {
        let trimmedInterest = newInterest.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedInterest.isEmpty {
            viewModel.addInterest(trimmedInterest)
            newInterest = ""
        }
    }
    
    private func loadImage() {
        guard let inputImage = inputImage else { return }
        viewModel.uploadProfileImage(inputImage)
    }
}

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.headline)
            .foregroundColor(.primary)
    }
}

struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
            TextField(placeholder, text: $text)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.blue.opacity(0.5), lineWidth: 1)
        )
    }
}

struct InterestTag: View {
    let interest: String
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "tag.fill")
                .foregroundColor(.blue)
            Text(interest)
                .font(.subheadline)
            Spacer()
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
                    .imageScale(.medium)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.blue.opacity(0.1))
        .foregroundColor(.blue)
        .cornerRadius(20)
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
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
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleUser = User(
            id: UUID().uuidString,
            username: "johndoe",
            email: "john@example.com",
            fullName: "John Doe",
            bio: "Software Developer with a passion for mobile apps.",
            interests: ["Swift", "SwiftUI", "Combine"],
            profileImageURL: URL(string: "https://example.com/profile.jpg"),
            joinDate: Date(),
            activities: []
        )
        
        let viewModel = ProfileViewModel(userId: sampleUser.id)
        
        return EditProfileView(viewModel: viewModel)
    }
}
