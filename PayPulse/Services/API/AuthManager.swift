//
//  AuthManager.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-06-29.
//

import Foundation
import SwiftUI
import OSLog
import Toasts

enum LoginContext {
    case login
    case signup
    case keychain
}

protocol AuthManagerProtocol: ObservableObject {
    var isAuthenticated: Bool { get }
    var username: String? { get }
    var accessToken: String? { get }
    var tokenType: String? { get }
    var pendingToast: ToastValue? { get }
    var loginContext: LoginContext? { get }
    
    func saveAuthenticationData(username: String, accessToken: String, tokenType: String)
    func logout()
    func setPendingToast(_ toast: ToastValue)
    func clearPendingToast()
    func setLoginContext(_ context: LoginContext)
    func clearLoginContext()
    // func handleUnauthorized() async
    
    var apiClient: (any APIClientProtocol)? { get set }
    var authService: AuthService? { get set }
    var invoiceService: InvoiceService? { get set }
    var userService: UserService? { get set }
    func setServices(
        apiClient: (any APIClientProtocol),
        authService: AuthService,
        invoiceService: InvoiceService,
        userService: UserService
    )
}

class AuthManager: AuthManagerProtocol {
    private static let logger = Logger(subsystem: "PayPulse", category: "AuthManager")
    @Published var isAuthenticated: Bool {
        didSet {
            UserDefaults.standard.set(isAuthenticated, forKey: "isAuthenticated")
            Self.logger.debug("isAuthenticated didSet: \(self.isAuthenticated, privacy: .public)")
        }
    }
    
    @Published var pendingToast: ToastValue?
    @Published var loginContext: LoginContext?
    
    var username: String? {
        get { KeychainHelper.load(key: "username") }
        set {
            if let newValue = newValue {
                KeychainHelper.save(key: "username", value: newValue)
            } else {
                KeychainHelper.delete(key: "username")
            }
        }
    }
    
    var accessToken: String? {
        get { KeychainHelper.load(key: "accessToken") }
        set {
            if let newValue = newValue {
                KeychainHelper.save(key: "accessToken", value: newValue)
            } else {
                KeychainHelper.delete(key: "accessToken")
            }
        }
    }
    
    var tokenType: String? {
        get { KeychainHelper.load(key: "tokenType") }
        set {
            if let newValue = newValue {
                KeychainHelper.save(key: "tokenType", value: newValue)
            } else {
                KeychainHelper.delete(key: "tokenType")
            }
        }
    }
    
    var apiClient: (any APIClientProtocol)?
    var authService: AuthService?
    var invoiceService: InvoiceService?
    var userService: UserService?
    
    // this class will be singleton
    static let shared = AuthManager()
    
    private init() {
        let initialAccessToken = KeychainHelper.load(key: "accessToken")
        let isAuthenticatedFromKeychain = initialAccessToken != nil && !(initialAccessToken?.isEmpty ?? true)
        _isAuthenticated = Published(initialValue: isAuthenticatedFromKeychain)
        
        // Set login context to keychain if user is already authenticated
        if isAuthenticatedFromKeychain {
            _loginContext = Published(initialValue: .keychain)
        }
        
        // _isAuthenticated = Published(initialValue: false)
        Self.logger.debug("AuthManager initialized. Initial isAuthenticated: \(self.isAuthenticated, privacy: .public)")
    }
    
    func setServices(apiClient: (any APIClientProtocol), authService: AuthService, invoiceService: InvoiceService, userService: UserService) {
        Task { @MainActor in
            self.apiClient = apiClient
            self.authService = authService
            self.invoiceService = invoiceService
            self.userService = userService
            Self.logger.debug("AuthManager services set.")
        }
    }
    
    func saveAuthenticationData(username: String, accessToken: String, tokenType: String) {
        Task { @MainActor in
            self.username = username
            self.accessToken = accessToken
            self.tokenType = tokenType
            self.isAuthenticated = true
            Self.logger.info("Authentication data saved. User '\(username, privacy: .public)' is now authenticated.")
        }
    }
    
    func logout() {
        Task { @MainActor in
            self.username = nil
            self.accessToken = nil
            self.tokenType = nil
            self.isAuthenticated = false
            Self.logger.notice("User logged out. All authentication data has been cleared. isAuthenticated: \(self.isAuthenticated, privacy: .public)")
        }
    }
    
    func setPendingToast(_ toast: ToastValue) {
        Task { @MainActor in
            self.pendingToast = toast
            Self.logger.debug("Pending toast set")
        }
    }
    
    func clearPendingToast() {
        Task { @MainActor in
            self.pendingToast = nil
            Self.logger.debug("Pending toast cleared")
        }
    }
    
    func setLoginContext(_ context: LoginContext) {
        Task { @MainActor in
            self.loginContext = context
            Self.logger.debug("Login context set: \(String(describing: context))")
        }
    }
    
    func clearLoginContext() {
        Task { @MainActor in
            self.loginContext = nil
            Self.logger.debug("Login context cleared")
        }
    }
}
