import SwiftUI

struct OnboardingView: View {
    @ObservedObject var authManager: AuthenticationManager 
    @Binding var isSignedIn: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                NavigationLink(destination: SignUpView(authManager: authManager)) {
                    Text("Sign Up")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                NavigationLink(destination:
                                SignInView(
                                    authManager: authManager,
                                    isSignedIn: $isSignedIn
                                )
                ) {
                    Text("Sign In")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
            .navigationTitle("LittleCakesNL")
        }
    }
}
