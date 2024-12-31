import FirebaseAuth
import FirebaseFirestore

final class AuthenticationManager: ObservableObject {
    @Published var isLoading: Bool = true
    @Published var isSignedIn: Bool = false
    
    let firestoreManager: FirestoreManager
    private let auth: Auth
    private let db: Firestore
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    
    init(firestoreManager: FirestoreManager) {
        self.firestoreManager = firestoreManager
        self.auth = firestoreManager.auth
        self.db = firestoreManager.db

        startListening()
    }
    
    func startListening() {
        authStateListenerHandle = auth.addStateDidChangeListener { [weak self] _, user in
            self?.isLoading = false
            self?.isSignedIn = user != nil
        }
    }
    
    deinit {
        if let handle = authStateListenerHandle {
            auth.removeStateDidChangeListener(handle)
        }
    }

    /// Sign up with email and password
    func signUp(
        email: String,
        password: String,
        name: String,
        role: String = "user",
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

    func fetchUser(userId: String, completion: @escaping (User?, Error?) -> Void) {
        db.collection("users").document(userId).getDocument { snapshot, error in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let snapshot = snapshot, snapshot.exists else {
                completion(nil, nil)
                return
            }

            do {
                // Decode the snapshot data into a User object
                let user = try snapshot.data(as: User.self)
                completion(user, nil)
            } catch {
                completion(nil, error)
            }
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

