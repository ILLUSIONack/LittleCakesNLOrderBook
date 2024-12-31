import SwiftUI

struct SignUpView: View {
    @ObservedObject var authManager: AuthenticationManager

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var name: String = ""  // Added name property
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
            
            SecureField("Password", text: $password)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)

            TextField("Name", text: $name)  // Added TextField for Name
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)

            Button(action: signUp) {
                Text("Sign Up")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Notice"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private func signUp() {
        // Ensure the required fields are set (email, password, name)
        guard !email.isEmpty, !password.isEmpty, !name.isEmpty else {
            alertMessage = "Please fill in all fields"
            showAlert = true
            return
        }
        
        authManager.signUp(email: email, password: password, name: name, role: "user") { authResult, error in
            if let error = error {
                alertMessage = "Error: \(error.localizedDescription)"
            } else {
                alertMessage = "Sign-up successful! You can now log in."
            }
            showAlert = true
        }
    }
}
