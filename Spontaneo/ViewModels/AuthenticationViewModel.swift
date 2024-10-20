import Foundation
import Combine

class AuthenticationViewModel: ObservableObject {
    @Published var username = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var isValid = false
    
    private var cancellables = Set<AnyCancellable>()
    private let authService: AuthenticationService
    
    init(authService: AuthenticationService) {
        self.authService = authService
        
        isFormValidPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.isValid, on: self)
            .store(in: &cancellables)
    }
    
    private var isFormValidPublisher: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest4(isUsernameValidPublisher, isEmailValidPublisher, isPasswordValidPublisher, arePasswordsMatchingPublisher)
            .map { $0 && $1 && $2 && $3 }
            .eraseToAnyPublisher()
    }
    
    private var isUsernameValidPublisher: AnyPublisher<Bool, Never> { 
        $username
            .map { !$0.isEmpty }
            .eraseToAnyPublisher()
    }
    
    private var isEmailValidPublisher: AnyPublisher<Bool, Never> {
        $email
            .map { $0.contains("@") && $0.contains(".") }
            .eraseToAnyPublisher()
    }
    
    private var isPasswordValidPublisher: AnyPublisher<Bool, Never> {
        $password
            .map { $0.count >= 6 }
            .eraseToAnyPublisher()
    }
    
    private var arePasswordsMatchingPublisher: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest($password, $confirmPassword)
            .map { $0 == $1 }
            .eraseToAnyPublisher()
    }
    
    func login() {
        authService.signIn(email: email, password: password)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Login error: \(error.localizedDescription)")
                }
            } receiveValue: { user in
                print("Successfully logged in user: \(user.id)")
            }
            .store(in: &cancellables)
    }
    
    func signUp() {
        authService.signUp(username: username, email: email, password: password)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Sign up error: \(error.localizedDescription)")
                }
            } receiveValue: { user in
                print("Successfully signed up user: \(user.id)")
            }
            .store(in: &cancellables)
    }
}
