import SwiftUI

final class ImageCache {
    static let shared = NSCache<NSURL, UIImage>()
}

struct BottomTabView: View {
    @ObservedObject var firestoreManager: FirestoreManager
    @StateObject private var viewModel: BottomTabViewModel
    private let filloutService: FilloutService = FilloutService()

    init(firestoreManager: FirestoreManager) {
        self.firestoreManager = firestoreManager
        _viewModel = StateObject(wrappedValue: BottomTabViewModel(firestoreManager: firestoreManager))
    }
    
    var body: some View {
        TabView {
            SubmissionsView(firestoreManager: firestoreManager, filloutService: filloutService)
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Orders")
                }
                .badge(viewModel.unviewedSubmissionsCount) 
        }
    }
}
