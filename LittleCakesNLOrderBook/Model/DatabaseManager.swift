import Foundation
import FirebaseFirestore

final class FirestoreManager: ObservableObject {
    static let shared = FirestoreManager()
    
    private init() {
        db = Firestore.firestore()
    }
    
    private(set) var db: Firestore
}
