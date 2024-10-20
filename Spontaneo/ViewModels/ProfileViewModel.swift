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
    
    private func updateUserProfileImage(_ url: URL?) {
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
                self?.profileImage = nil
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
    
    func deleteProfileImage() {
        guard let imageURL = user.profileImageURL else {
            errorMessage = "No profile image to delete"
            return
        }
        
        isLoading = true
        let imageRef = storage.child("profile_images/\(imageURL.lastPathComponent)")
        
        imageRef.delete { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
                return
            }
            
            self.updateUserProfileImage(nil)
        }
    }
}

protocol UserServiceProtocol {
    func fetchUser(userId: String) -> AnyPublisher<User, Error>
    func updateUser(_ user: User) -> AnyPublisher<User, Error>
    func uploadProfileImage(_ image: UIImage) -> AnyPublisher<URL, Error>
}

class MockUserService: UserServiceProtocol {
    func fetchUser(userId: String) -> AnyPublisher<User, Error> {
            return Just(User.sampleUser)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    
    func updateUser(_ user: User) -> AnyPublisher<User, Error> {
        Just(user)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func uploadProfileImage(_ image: UIImage) -> AnyPublisher<URL, Error> {
        Just(URL(string: "https://example.com/profile.jpg")!)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

class UserService: UserServiceProtocol {
    private let db = Firestore.firestore()
    private let storage = Storage.storage().reference()

    func fetchUser(userId: String) -> AnyPublisher<User, Error> {
        return Future { promise in
            self.db.collection("users").document(userId).getDocument { (document, error) in
                if let error = error {
                    promise(.failure(error))
                } else if let document = document, document.exists {
                    do {
                        var user = try document.data(as: User.self)
                        user.id = document.documentID
                        promise(.success(user))
                    } catch {
                        promise(.failure(error))
                    }
                } else {
                    promise(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found"])))
                }
            }
        }.eraseToAnyPublisher()
    }

    func updateUser(_ user: User) -> AnyPublisher<User, Error> {
        return Future { promise in
            do {
                try self.db.collection("users").document(user.id).setData(from: user) { error in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        promise(.success(user))
                    }
                }
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }

    func uploadProfileImage(_ image: UIImage) -> AnyPublisher<URL, Error> {
        return Future { promise in
            guard let imageData = image.jpegData(compressionQuality: 0.5) else {
                promise(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])))
                return
            }
            
            let imageName = UUID().uuidString
            let imageRef = self.storage.child("profile_images/\(imageName).jpg")
            
            imageRef.putData(imageData, metadata: nil) { (metadata, error) in
                if let error = error {
                    promise(.failure(error))
                } else {
                    imageRef.downloadURL { (url, error) in
                        if let error = error {
                            promise(.failure(error))
                        } else if let url = url {
                            promise(.success(url))
                        }
                    }
                }
            }
        }.eraseToAnyPublisher()
    }
}
