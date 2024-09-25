import Firebase
import FirebaseAuth
import FirebaseFirestore
import Combine

class AuthenticationService: ObservableObject {
    @Published var user: User?
    private var cancellables = Set<AnyCancellable>()
    private let db = Firestore.firestore()
    
    init() {
        Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            if let firebaseUser = firebaseUser {
                self?.fetchUser(firebaseUser: firebaseUser)
            } else {
                self?.user = nil
            }
        }
    }
    
    private func fetchUser(firebaseUser: FirebaseAuth.User) {
        db.collection("users").document(firebaseUser.uid).getDocument { [weak self] (document, error) in
            if let document = document, document.exists {
                do {
                    var user = try document.data(as: User.self)
                    user.id = document.documentID
                    self?.user = user
                } catch {
                    print("Error decoding user: \(error)")
                }
            } else {
                print("User document does not exist")
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
