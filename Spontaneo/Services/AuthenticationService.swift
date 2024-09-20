import Firebase
import FirebaseAuth
import Combine

class AuthenticationService: ObservableObject {
    @Published var user: User?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            if let firebaseUser = firebaseUser {
                self?.user = User(id: firebaseUser.uid, username: firebaseUser.displayName ?? "", email: firebaseUser.email ?? "", fullName: "", bio: "", interests: [], profileImageURL: firebaseUser.photoURL, joinDate: Date(), activities: [])
            } else {
                self?.user = nil
            }
        }
    }
    
    func signUp(username: String, email: String, password: String) -> AnyPublisher<User, Error> {
        Deferred {
            Future { promise in
                Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                    if let error = error {
                        promise(.failure(error))
                    } else if let firebaseUser = authResult?.user {
                        let user = User(id: firebaseUser.uid, username: username, email: email, fullName: "", bio: "", interests: [], profileImageURL: nil, joinDate: Date(), activities: [])
                        promise(.success(user))
                    }
                }
            }
        }
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
    }
    
    func signIn(email: String, password: String) -> AnyPublisher<User, Error> {
        Deferred {
            Future { promise in
                Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                    if let error = error {
                        promise(.failure(error))
                    } else if let firebaseUser = authResult?.user {
                        let user = User(id: firebaseUser.uid, username: firebaseUser.displayName ?? "", email: email, fullName: "", bio: "", interests: [], profileImageURL: firebaseUser.photoURL, joinDate: Date(), activities: [])
                        promise(.success(user))
                    }
                }
            }
        }
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}
