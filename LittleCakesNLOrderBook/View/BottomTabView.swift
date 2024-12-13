import SwiftUI

final class ImageCache {
    static let shared = NSCache<NSURL, UIImage>()
}

struct BottomTabView: View {
    @EnvironmentObject var firestoreManager: FirestoreManager
    @StateObject private var viewModel: BottomTabViewModel
    private let filloutService: FilloutService = FilloutService()

    init() {
        _viewModel = StateObject(wrappedValue: BottomTabViewModel(firestoreManager: FirestoreManager.shared))
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
