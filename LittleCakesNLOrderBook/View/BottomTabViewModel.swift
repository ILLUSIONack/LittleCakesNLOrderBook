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
    
    // Function to fetch the unviewed submissions count
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

    func fetchAndMapSubmissionsByType(
        _ type: SubmissionType,
        completion: @escaping ([MappedSubmission]?, Error?) -> Void
    ) {
        let submissionsCollection = db.collection(ServerConfig.shared.collectionName)
        
        // Query to fetch documents where `type` matches the provided value
        submissionsCollection.whereField("type", isEqualTo: type.rawValue).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching submissions by type: \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No submissions found for type: \(type.rawValue)")
                completion([], nil)
                return
            }
            
            do {
                // Decode the documents into `FirebaseSubmission` objects
                let firebaseSubmissions = try documents.map { document in
                    try document.data(as: FirebaseSubmission.self)
                }
                
                // Map FirebaseSubmission to MappedSubmission (without legacy fields)
                let mappedSubmissions = firebaseSubmissions.map { submission in
                    MappedSubmission(
                        collectionId: submission.id ?? "",
                        submissionId: submission.submissionId,
                        submissionTime: submission.submissionTime,
                        lastUpdatedAt: submission.lastUpdatedAt,
                        questions: submission.questions,
                        type: submission.type,
                        state: submission.state
                    )
                }
                
                completion(mappedSubmissions, nil)
            } catch {
                print("Error decoding or mapping submissions: \(error.localizedDescription)")
                completion(nil, error)
            }
        }
    }
}
