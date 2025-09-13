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
    @State var name     : String = ""
    @State var email    : String = ""
    @State var password : String = ""
    @State var gmailPassword : String = ""
    @Binding var isLoading: Bool
    
    @ObservedObject var viewModel: AuthViewModel
    
    init(authService: AuthService, toggleAuthView: @escaping () -> Void, isLoading: Binding<Bool>) {
        self.authService = authService
        self.viewModel = AuthViewModel(authService: authService)
        self.toggleAuthView = toggleAuthView
        self._isLoading = isLoading
    }
    
    var body: some View {
        VStack {
            /// MARK: Signup form
            
            VStack(alignment: .center, spacing: 20) {
                LabeledTextField(
                    text: $name,
                    placeholderText: "Enter your full name",
                    labelText: "Name"
                )
                
                LabeledTextField(
                    text: $email,
                    placeholderText: "Enter your email address",
                    labelText: "Email address"
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
                        Task {
                            isLoading = true
                            defer {
                                isLoading = false
                            }
                            await viewModel.signup(
                                username: name,
                                email: email,
                                password: password,
                                gmailAppPassword: gmailPassword
                            )
                        }
                    }
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
}

#Preview {
    let authManager = AuthManager.shared
    let apiClient = PayPulseAPIClient(authManager: authManager)
    let authService = AuthService(apiClient: apiClient, authManager: authManager)
    SignupView(authService: authService, toggleAuthView: {}, isLoading: .constant(false))
}
