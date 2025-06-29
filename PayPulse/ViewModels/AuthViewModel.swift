//
//  AuthViewModel.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-06-29.
//

import Foundation
import SwiftUI

class AuthViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let authService: AuthService
    
    init(authService: AuthService) {
        self.authService = authService
    }
    
    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        let request = LoginRequest(email: email, password: password)
        do {
            let authenticationData = try await authService.login(request: request)
            print("Login successful! User: \(authenticationData.username)")
        } catch {
            errorMessage = (error as? APIError)?.localizedDescription ?? "An unknown login error occurred."
            print("Login failed: \(errorMessage)")
        }
        isLoading = false
    }
    
    func signup(username: String, email: String, password: String, gmailAppPassword: String) async {
        isLoading = true
        errorMessage = nil
        
        let request = SignupRequest(name: username, email: email, password: password, gmailAppPassword: gmailAppPassword)
        do {
            let authenticationData = try await authService.signup(request: request)
            print("Signup successful! User: \(authenticationData.username)")
        } catch {
            errorMessage = (error as? APIError)?.localizedDescription ?? "An unknown signup error occurred."
            print("Signup failed: \(errorMessage)")
        }
        isLoading = false
    }
    
    func clearErrors() {
        errorMessage = nil
        isLoading = false
    }
}
