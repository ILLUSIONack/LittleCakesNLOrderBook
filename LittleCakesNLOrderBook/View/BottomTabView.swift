import SwiftUI

final class ImageCache {
    static let shared = NSCache<NSURL, UIImage>()
}

struct BottomTabView: View {
    @EnvironmentObject var firestoreManager: FirestoreManager
    @StateObject private var viewModel: BottomTabViewModel

    init() {
        _viewModel = StateObject(wrappedValue: BottomTabViewModel(firestoreManager: FirestoreManager.shared))
    }
    var body: some View {
        TabView {
            SubmissionsView(submissionState: .orders, firestoreManager: firestoreManager)
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Orders")
                }
            if viewModel.isConfirmedTabVisible {
                SubmissionsView(submissionState: .confirmed, firestoreManager: firestoreManager)
                    .tabItem {
                        Image(systemName: "checkmark.seal.fill")
                        Text("Confirmed")
                    }
            }
            if viewModel.isCompletedTabVisible {
                SubmissionsView(submissionState: .completed, firestoreManager: firestoreManager)
                    .tabItem {
                        Image(systemName: "square.and.pencil")
                        Text("Completed")
                    }
            }
            if viewModel.isDeletedTabVisible {
                SubmissionsView(submissionState: .deleted, firestoreManager: firestoreManager)
                    .tabItem {
                        Image(systemName: "delete.left.fill")
                        Text("Deleted")
                    }
            }
        }
        .onAppear {
            viewModel.fetchSubmissions()
        }
    }
}
