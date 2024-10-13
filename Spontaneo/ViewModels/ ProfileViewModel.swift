import SwiftUI
import Combine
import Firebase
import FirebaseFirestore
import FirebaseStorage

class ProfileViewModel: ObservableObject {
    @Published var user: User
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var profileImage: UIImage?
    
    private var cancellables = Set<AnyCancellable>()
    private let userService: UserServiceProtocol
    private let storage = Storage.storage().reference()
    
    init(userId: String, userService: UserServiceProtocol = UserService()) {
        self.user = User.sampleUser
        self.userService = userService
        
        fetchUser(userId: userId)
    }
    
    func uploadProfileImage(_ image: UIImage) {
        isLoading = true
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            errorMessage = "Failed to convert image to data"
            isLoading = false
            return
        }
        
        let imageName = UUID().uuidString
        let imageRef = storage.child("profile_images/\(imageName).jpg")
        
        imageRef.putData(imageData, metadata: nil) { [weak self] (metadata, error) in
            guard let self = self else { return }
            
            if let error = error {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
                return
            }
            
            imageRef.downloadURL { (url, error) in
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    return
                }
                
                guard let downloadURL = url else {
                    self.errorMessage = "Failed to get download URL"
                    self.isLoading = false
                    return
                }
                
                self.updateUserProfileImage(downloadURL)
            }
        }
    }
    
    private func updateUserProfileImage(_ url: URL) {
        var updatedUser = user
        updatedUser.profileImageURL = url
        
        userService.updateUser(updatedUser)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] updatedUser in
                self?.user = updatedUser
                self?.objectWillChange.send() // Notify observers that the user object has changed
            }
            .store(in: &cancellables)
    }

    // ... (keep other existing methods)
}
