import SwiftUI
import Combine

class ProfileViewModel: ObservableObject {
    @Published var user: User
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let userService: UserServiceProtocol
    
    init(user: User, userService: UserServiceProtocol = UserService()) {
        self.user = user
        self.userService = userService
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
    
    func updateProfileImage(_ image: UIImage) {
        isLoading = true
        userService.uploadProfileImage(image)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] imageURL in
                self?.user.profileImageURL = imageURL
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

protocol UserServiceProtocol {
    func updateUser(_ user: User) -> AnyPublisher<User, Error>
    func uploadProfileImage(_ image: UIImage) -> AnyPublisher<URL, Error>
}

class MockUserService: UserServiceProtocol {
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
    func updateUser(_ user: User) -> AnyPublisher<User, Error> {
        return MockUserService().updateUser(user)
    }
    
    func uploadProfileImage(_ image: UIImage) -> AnyPublisher<URL, Error> {
        return MockUserService().uploadProfileImage(image)
    }
}
