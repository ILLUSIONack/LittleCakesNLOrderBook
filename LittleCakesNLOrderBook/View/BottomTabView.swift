import SwiftUI

final class ImageCache {
    static let shared = NSCache<NSURL, UIImage>()
}

struct BottomTabView: View {
    @ObservedObject var authService: AuthenticationService
    @StateObject private var viewModel: BottomTabViewModel
    
    private let filloutService: FilloutService = FilloutService()

    init(authService: AuthenticationService) {
        self.authService = authService
        _viewModel = StateObject(wrappedValue: BottomTabViewModel(authService: authService))
    }
    
    var body: some View {
        TabView {
            if viewModel.isUserAdmin {
                SubmissionsView(
                    authenticationManager: authService,
                    filloutService: filloutService
                )
                .tabItem {
                    Label("Orders", systemImage: "list.bullet")
                }
                .badge(viewModel.unviewedSubmissionsCount)
                SubmissionsView(
                    authenticationManager: authService,
                    filloutService: filloutService,
                    isDelegated: true
                )
                .tabItem {
                    Label("Delegated", systemImage: "list.bullet")
                }
            } else {
                SubmissionsView(
                    authenticationManager: authService,
                    filloutService: filloutService
                )
                .tabItem {
                    Label("Orders", systemImage: "list.bullet")
                }
                .badge(viewModel.unviewedSubmissionsCount)
            }
        }
        .accentColor(.black)
    }
}
