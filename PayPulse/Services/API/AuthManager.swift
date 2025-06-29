//
//  AuthManager.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-06-29.
//

import Foundation
import SwiftUI

protocol AuthManagerProtocol: ObservableObject {
    var isAuthenticated: Bool { get }
    var username: String? { get }
    var accessToken: String? { get }
    var tokenType: String? { get }
    
    func saveAuthenticationData(username: String, accessToken: String, tokenType: String)
    func logout()
    // func handleUnauthorized() async
    
    var apiClient: (any APIClientProtocol)? { get set }
    var authService: AuthService? { get set }
    var invoiceService: InvoiceService? { get set }
    var userService: UserService? { get set }
    func setServices(apiClient: (any APIClientProtocol), authService: AuthService, invoiceService: InvoiceService, userService: UserService)
}

class AuthManager: AuthManagerProtocol {
    @Published var isAuthenticated: Bool {
        didSet {
            UserDefaults.standard.set(isAuthenticated, forKey: "isAuthenticated")
        }
    }
    
    // TODO: Use Keychain instead of AppStorage here
    @AppStorage("username") var username: String?
    @AppStorage("accessToken") var accessToken: String?
    @AppStorage("tokenType") var tokenType: String?
    
    var apiClient: (any APIClientProtocol)?
    var authService: AuthService?
    var invoiceService: InvoiceService?
    var userService: UserService?
    
    // this class will be singleton
    static let shared = AuthManager()
    
    private init() {
        // let initialAccessToken = KeychainHelper.load(key: "accessToken")
        // _isAuthenticated = Published(initialValue: initialAccessToken != nil && !initialAccessToken!.isEmpty)
        _isAuthenticated = Published(initialValue: false)
    }
    
    func setServices(apiClient: (any APIClientProtocol), authService: AuthService, invoiceService: InvoiceService, userService: UserService) {
        self.apiClient = apiClient
        self.authService = authService
        self.invoiceService = invoiceService
        self.userService = userService
    }
    
    func saveAuthenticationData(username: String, accessToken: String, tokenType: String) {
        self.username = username
        self.accessToken = accessToken
        self.tokenType = tokenType
        self.isAuthenticated = true
        print("AuthManager: Authentication data saved. User '\(username)' is now authenticated.")
        // KeychainHelper.save(key: "username", value: username)
        // KeychainHelper.save(key: "accessToken", value: accessToken)
        // KeychainHelper.save(key: "tokenType", value: tokenType)
    }
    
    func logout() {
        self.username = nil
        self.accessToken = nil
        self.tokenType = nil
        self.isAuthenticated = false
        print("AuthManager: User logged out. All authentication data has been cleared.")
        // KeychainHelper.delete(key: "username")
        // KeychainHelper.delete(key: "accessToken")
        // KeychainHelper.delete(key: "tokenType")
    }
}
