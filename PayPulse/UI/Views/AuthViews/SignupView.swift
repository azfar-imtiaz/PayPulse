//
//  SignupView.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-06-11.
//

import SwiftUI

struct SignupView: View {
    let authService: AuthService
    var toggleAuthView: () -> Void
    @State var username       : String = ""
    @State var email          : String = ""
    @State var password       : String = ""
    @State var disableSignup  : Bool = false
    @Binding var isLoading    : Bool
    @Binding var errorMessage : String
    @StateObject private var viewModel: AuthViewModel
    @EnvironmentObject var authManager: AuthManager
    
    init(authService: AuthService, toggleAuthView: @escaping () -> Void, isLoading: Binding<Bool>, errorMessage: Binding<String>) {
        self.authService = authService
        self.toggleAuthView = toggleAuthView
        self._isLoading = isLoading
        self._errorMessage = errorMessage
        
        // Initialize AuthViewModel with authService and authManager
        self._viewModel = StateObject(wrappedValue: AuthViewModel(authService: authService, authManager: AuthManager.shared, errorMessage: errorMessage))
    }
    
    var body: some View {
        VStack {
            /// MARK: Signup form
            
            VStack(alignment: .center, spacing: 20) {
                LabeledTextField(
                    text: $username,
                    placeholderText: "Enter your full name",
                    labelText: "Name"
                )
                
                LabeledTextField(
                    text: $email,
                    placeholderText: "Enter your email address",
                    labelText: "Email address",
                    isEmail: true
                )
                
                LabeledTextField(
                    text: $password,
                    placeholderText: "Enter your password",
                    labelText: "Password",
                    isSecure: true
                )
                
                PrimaryButton(
                    buttonView: Text("Sign up"),
                    action: {
                        signupUser(username: username, email: email, password: password)
                    },
                    isDisabled: disableSignup
                )
                .padding(.top)
                
                HStack(spacing: 0) {
                    Text("Already have an account? ")
                        .font(.bodySmall)
                        .foregroundStyle(Color.secondaryDarkGray)
                    
                    TextButton(
                        buttonText: "Sign in!",
                        textColor: Color.accentColorOrange,
                        font: .bodySmall,
                        action: {
                            toggleAuthView()
                        }
                    )
                }
            }
        }
    }
    
    func signupUser(username: String, email: String, password: String) {
        Task {
            let (status, message) = ValidationService.validateSignupFields(name: username, email: email, password: password)
            guard status else {
                disableSignup = true
                errorMessage = message
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    errorMessage = ""
                    disableSignup = false
                }
                return
            }
            
            isLoading = true
            defer {
                isLoading = false
            }
            await viewModel.signup(
                username: username,
                email: email,
                password: password
            )
        }
    }
}

#Preview {
    let authManager = AuthManager.shared
    let apiClient = PayPulseAPIClient(authManager: authManager)
    let authService = AuthService(apiClient: apiClient, authManager: authManager)
    SignupView(authService: authService, toggleAuthView: {}, isLoading: .constant(false), errorMessage: .constant(""))
}
