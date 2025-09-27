//
//  AuthViewModel.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-06-29.
//

import Foundation
import SwiftUI
import Toasts

class AuthViewModel: ObservableObject {
    @Published var isLoading = false
    @Binding var errorMessage: String
    
    private let authService: AuthService
    private let authManager: any AuthManagerProtocol
    
    init(authService: AuthService, authManager: any AuthManagerProtocol, errorMessage: Binding<String>) {
        self.authService = authService
        self.authManager = authManager
        self._errorMessage = errorMessage
    }
    
    func login(email: String, password: String) async {
        errorMessage = ""
        
        let (status, message) = ValidationService.validateLoginFields(email: email, password: password)
        guard status else {
            errorMessage = message
            return
        }
        
        // Set login context and welcome toast before attempting login
        authManager.setLoginContext(.login)
        let welcomeToast = ToastValue(
            icon: Icon(name: "circle-check"),
            message: "Welcome back!"
        )
        authManager.setPendingToast(welcomeToast)
        
        let request = LoginRequest(email: email, password: password)
        do {
            let authenticationData = try await authService.login(request: request)
            print("Login successful! User: \(authenticationData.username)")
        } catch {
            // Clear context and toast on failure
            errorMessage = (error as? APIError)?.errorDescription ?? "An unknown login error occurred."
            print("Login failed: \(errorMessage)")
        }
    }
    
    func signup(username: String, email: String, password: String) async {
        errorMessage = ""
        
        // Set signup context and welcome toast before attempting signup
        authManager.setLoginContext(.signup)
        let welcomeToast = ToastValue(
            icon: Icon(name: "circle-check"),
            message: "Welcome to PayPulse!"
        )
        authManager.setPendingToast(welcomeToast)
        
        let request = SignupRequest(name: username, email: email, password: password)
        do {
            let authenticationData = try await authService.signup(request: request)
            print("Signup successful! User: \(authenticationData.username)")
        } catch {
            // Clear context and toast on failure
            errorMessage = (error as? APIError)?.errorDescription ?? "An unknown signup error occurred."
            print("Signup failed: \(errorMessage)")
        }
    }
}
