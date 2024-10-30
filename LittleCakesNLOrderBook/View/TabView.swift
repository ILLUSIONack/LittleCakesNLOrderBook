import SwiftUI

final class ImageCache {
    static let shared = NSCache<NSURL, UIImage>()
}

struct BottomTabView: View {
    @EnvironmentObject var firestoreManager: FirestoreManager
    @StateObject private var viewModel: TabViewModel

    init() {
        _viewModel = StateObject(wrappedValue: TabViewModel(firestoreManager: FirestoreManager.shared))
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
                        Image(systemName: "arrow.up.trash.fill")
                        Text("Deleted")
                    }
            }
        }
        .onAppear {
            viewModel.fetchSubmissions()
        }
    }
}
