import FirebaseAuth
import FirebaseFirestore
import Combine

protocol AuthenticationServiceProtocol {
    var currentUserPublisher: AnyPublisher<User?, Never> { get }
    var isSignedInPublisher: AnyPublisher<Bool, Never> { get }
    
    func fetchUserProfile(userId: String)
    func signOut(completion: @escaping (Error?) -> Void)
}

final class AuthenticationService: ObservableObject, AuthenticationServiceProtocol {
    @Published var isLoading: Bool = true
    @Published var isSignedIn: Bool = false
    @Published var currentUser: User?
    
    let firestoreManager: FirestoreManager
    private var listener: ListenerRegistration?
    private let auth: Auth
    private let db: Firestore
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    
    private var cancellables = Set<AnyCancellable>()
    
    // Subjects
    private let currentUserSubject = CurrentValueSubject<User?, Never>(nil)
    private let isSignedInSubject = CurrentValueSubject<Bool, Never>(false)
    
    var currentUserPublisher: AnyPublisher<User?, Never> {
        currentUserSubject.eraseToAnyPublisher()
    }
    
    var isSignedInPublisher: AnyPublisher<Bool, Never> {
        isSignedInSubject.eraseToAnyPublisher()
    }
    
    init(firestoreManager: FirestoreManager) {
        self.firestoreManager = firestoreManager
        self.auth = firestoreManager.auth
        self.db = firestoreManager.db

        startListening()
        isSignedInPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$isSignedIn)
        
        currentUserPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$currentUser)
    }
    
    func startListening() {
        authStateListenerHandle = auth.addStateDidChangeListener { [weak self] _, user in
            guard let self else { return }
            let isSignedIn = user != nil
            isSignedInSubject.send(isSignedIn)
            if isSignedIn, let user {
                fetchUserProfile(userId: user.uid)
            }
            isLoading = false
        }
    }
    
    deinit {
        if let handle = authStateListenerHandle {
            auth.removeStateDidChangeListener(handle)
        }
    }
    
    func fetchUserProfile(userId: String) {
        listener = db.collection("users").document(userId).addSnapshotListener({ [weak self] snapshot, error in
            guard let self = self else { return }

            if let error = error {
                print("Error fetching user profile: \(error.localizedDescription)")
                return
            }

            if let document = snapshot, document.exists {
                // Map the document data to your `User` model and update currentUser
                do {
                    let user = try document.data(as: User.self)
                    self.currentUserSubject.send(user)
                } catch {
                    print("Error mapping document to User model: \(error.localizedDescription)")
                }
            }
        })
    }

    /// Sign up with email and password
    func signUp(
        email: String,
        password: String,
        name: String,
        role: UserRole = .user,
        completion: @escaping (AuthDataResult?, Error?) -> Void
    ) {
        auth.createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let authResult = authResult else {
                completion(nil, nil)
                return
            }

            // Create the user model
            let user = User(
                id: authResult.user.uid,
                name: name,
                email: email,
                role: role,
                createdAt: Date(),
                updatedAt: Date()
            )
            
            // Save the user to Firestore
            self.saveUserToFirestore(user) { documentError in
                completion(authResult, documentError)
            }
        }
    }

    private func saveUserToFirestore(_ user: User, completion: @escaping (Error?) -> Void) {
        let userRef = db.collection("users").document(user.id)
        
        do {
            // Set the user data into Firestore
            try userRef.setData(from: user) { error in
                completion(error)
            }
        } catch {
            completion(error)
        }
    }

    func signIn(email: String, password: String, completion: @escaping (AuthDataResult?, Error?) -> Void) {
        auth.signIn(withEmail: email, password: password) { authResult, error in
            completion(authResult, error)
        }
    }

    func signOut(completion: @escaping (Error?) -> Void) {
        do {
            try auth.signOut()
            completion(nil)
        } catch let signOutError {
            completion(signOutError)
        }
    }
}

