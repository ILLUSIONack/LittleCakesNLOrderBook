import SwiftUI
import FirebaseCore
import FirebaseAuth
import Firebase
import Lottie

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        EnvLoader.loadEnv()
        let _ = ServerConfig.shared
        FirebaseApp.configure()
        
        return true
    }
}

@main
struct LittleCakesNLAgenaApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject private var authManager = AuthenticationManager(firestoreManager: FirestoreManager())
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authManager.isLoading {
                    VStack {
                        Spacer()
                        LottieView(animationName: "loading")
                            .frame(width: 100, height: 100)
                        Spacer()
                    }
                } else if authManager.isSignedIn {
                    BottomTabView(authenticationManager: authManager)
                } else {
                    OnboardingView(authManager: authManager, isSignedIn: $authManager.isSignedIn)
                }
            }
        }
    }
}
