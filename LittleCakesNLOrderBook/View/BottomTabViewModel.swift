import Foundation
import SwiftUI
import FirebaseFirestore

final class BottomTabViewModel: ObservableObject {

    private var listener: ListenerRegistration?
    @Published var isConfirmedTabVisible: Bool = false
    @Published var isCompletedTabVisible: Bool = false
    @Published var isDeletedTabVisible: Bool = false

    private var db: Firestore
    
    init(firestoreManager: FirestoreManager) {
        self.db = firestoreManager.db
        fetchSubmissions()
    }
    
    func fetchSubmissions() {
        listener?.remove()

        listener = db.collection(ServerConfig.shared.collectionName).addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error fetching submissions from Firestore: \(error)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No documents found in Firestore")
                return
            }
            
            let firebaseSubmissions = documents.compactMap { queryDocumentSnapshot in
                do {
                    return try queryDocumentSnapshot.data(as: FirebaseSubmission.self)
                } catch {
                    print("Failed to decode document: \(error)")
                    return nil
                }
            }
            
            self.isCompletedTabVisible = firebaseSubmissions.contains { sub in
                return sub.isCompleted == true
            }
            self.isConfirmedTabVisible = firebaseSubmissions.contains { sub in
                return sub.isConfirmed == true
            }
            self.isDeletedTabVisible = firebaseSubmissions.contains { sub in
                return sub.isDeleted == true
            }
            
        }
    }
    
    deinit {
        listener?.remove()
    }
}

