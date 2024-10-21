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
    
    private func fetchUser(userId: String) {
        isLoading = true
        userService.fetchUser(userId: userId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] user in
                self?.user = user
            }
            .store(in: &cancellables)
    }
    
    var formattedJoinDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: user.joinDate)
    }
    
    func updateProfile(fullName: String, bio: String) {
        isLoading = true
        var updatedUser = user
        updatedUser.fullName = fullName
        updatedUser.bio = bio
        
        userService.updateUser(updatedUser)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] updatedUser in
                self?.user = updatedUser
            }
            .store(in: &cancellables)
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
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    func addInterest(_ interest: String) {
        var updatedInterests = user.interests
        updatedInterests.append(interest)
        updateInterests(updatedInterests)
    }
    
    func removeInterests(at offsets: IndexSet) {
        var updatedInterests = user.interests
        updatedInterests.remove(atOffsets: offsets)
        updateInterests(updatedInterests)
    }
    
    private func updateInterests(_ interests: [String]) {
        isLoading = true
        var updatedUser = user
        updatedUser.interests = interests
        
        userService.updateUser(updatedUser)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] updatedUser in
                self?.user = updatedUser
            }
            .store(in: &cancellables)
    }
}
