import Foundation
import FirebaseFirestore
import FirebaseAuth

final class FirestoreManager: ObservableObject {
    static let shared = FirestoreManager()
    
    private(set) var db: Firestore
    private(set) var auth: Auth

    init() {
        db = Firestore.firestore()
        auth = Auth.auth()
    }
}
