//
//  LoginView.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-06-09.
//

import SwiftUI

struct LoginView: View {
    let authService: AuthService
    var toggleAuthView: () -> Void
    @State var email          : String = "azy.imtiaz@gmail.com"
    @State var password       : String = "PayPulse25!"
    @State var disableLogin   : Bool = false
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
            /// MARK: Login form
            VStack(alignment: .center, spacing: 20) {
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
                    buttonView: Text("Login"),
                    action: {
                        loginUser(email: email, password: password)
                    },
                    isDisabled: disableLogin
                )
                .padding(.top)
                
                HStack(spacing: 0) {
                    Text("No account? Let's ")
                        .font(.bodySmall)
                        .foregroundStyle(Color.secondaryDarkGray)
                    
                    TextButton(
                        buttonText: "create one!",
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
    
    func loginUser(email: String, password: String) {
        Task {
            let (status, message) = ValidationService.validateLoginFields(email: email, password: password)
            guard status else {
                disableLogin = true
                errorMessage = message
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    errorMessage = ""
                    disableLogin = false
                }
                return
            }
            isLoading = true
            
            defer {
                isLoading = false
            }
            
            await viewModel.login(email: email, password: password)
        }
    }
}

#Preview {
    let authManager = AuthManager.shared
    let apiClient = PayPulseAPIClient(authManager: authManager)
    let authService = AuthService(apiClient: apiClient, authManager: authManager)
    LoginView(authService: authService, toggleAuthView: {}, isLoading: .constant(false), errorMessage: .constant(""))
}
