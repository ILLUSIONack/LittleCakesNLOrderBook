import Foundation
import SwiftUI
import FirebaseFirestore

final class BottomTabViewModel: ObservableObject {
    private var db: Firestore
    private var listener: ListenerRegistration?
    
    @Published var unviewedSubmissionsCount: Int = 0
    
    init(firestoreManager: FirestoreManager) {
        self.db = firestoreManager.db
        fetchUnviewedSubmissionsCount()
    }
    
    func fetchUnviewedSubmissionsCount() {
        let submissionsCollection = db.collection(ServerConfig.shared.collectionName)
        
        listener = submissionsCollection.whereField("state", isEqualTo: "unviewed")
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print("Error fetching unviewed submissions count: \(error.localizedDescription)")
                    return
                }
                
                // Update the unviewedSubmissionsCount based on the snapshot
                if let snapshot = snapshot {
                    self?.unviewedSubmissionsCount = snapshot.count
                }
            }
    }
    
    deinit {
        listener?.remove()
    }
}
