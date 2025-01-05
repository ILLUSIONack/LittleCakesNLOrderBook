import SwiftUI

final class ImageCache {
    static let shared = NSCache<NSURL, UIImage>()
}

struct BottomTabView: View {
    @ObservedObject var authenticationManager: AuthenticationManager
    @ObservedObject var firestoreManager: FirestoreManager
    @StateObject private var viewModel: BottomTabViewModel
    private let filloutService: FilloutService = FilloutService()

    init(authenticationManager: AuthenticationManager) {
        self.authenticationManager = authenticationManager
        self.firestoreManager = authenticationManager.firestoreManager
        _viewModel = StateObject(wrappedValue: BottomTabViewModel(firestoreManager: authenticationManager.firestoreManager))
    }
    
    var body: some View {
        TabView {
            SubmissionsView(
                authenticationManager: authenticationManager,
                filloutService: filloutService
            )
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Orders")
                }
                .badge(viewModel.unviewedSubmissionsCount)
        }
        .accentColor(.black)
    }
}
