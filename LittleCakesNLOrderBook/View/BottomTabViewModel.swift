import Foundation
import SwiftUI
import FirebaseFirestore
import Combine

final class BottomTabViewModel: ObservableObject {
    private var db: Firestore
    private var listener: ListenerRegistration?
    private var authService: AuthenticationService
    private var cancellables = Set<AnyCancellable>()

    @Published var unviewedSubmissionsCount: Int = 0
    @Published var isUserAdmin: Bool = false
    
    init(authService: AuthenticationService) {
        self.db = authService.firestoreManager.db
        self.authService = authService
        observeCurrentUser()
    }
    
    private func observeCurrentUser() {
        authService.currentUserPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                guard let self else { return }
                isUserAdmin = user?.role == .admin
                if self.isUserAdmin {
                    self.fetchUnviewedSubmissionsCount()
                }
            }
            .store(in: &cancellables)
    }
    
    func fetchUnviewedSubmissionsCount() {
        listener = db.collection(ServerConfig.shared.collectionName).whereField("state", isEqualTo: "unviewed")
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
