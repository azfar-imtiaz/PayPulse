//
//  GmailAuthService.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-09-01.
//

import WebKit
import Security
import Foundation
import GoogleSignIn

class GmailAuthService {
    private let iOSClientID : String = "623709424238-bggrm8506j6fqc845ee862cv9jiqi60a.apps.googleusercontent.com"
    private let webClientID : String = "623709424238-2332dvgidmepsd23j603do3divuj5sh2.apps.googleusercontent.com"
    // private let config      : GIDConfiguration
    
    init() {
        configureGoogleSignIn()
    }
    
    func configureGoogleSignIn() {
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: iOSClientID, serverClientID: webClientID)
    }
    
    func signin(presentingViewController: UIViewController, completion: @escaping (Result<GmailAuthRequest, APIError>) -> Void) {
        
        GIDSignIn.sharedInstance.disconnect() { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Disconnect error (may be normal): \(error.localizedDescription)")
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self?.performFreshSignIn(presentingViewController: presentingViewController, completion: completion)
                }                
            }
        }
    }
    
    func performFreshSignIn(presentingViewController: UIViewController, completion: @escaping (Result<GmailAuthRequest, APIError>) -> Void) {
        
        GIDSignIn.sharedInstance.signIn(
            withPresenting: presentingViewController,
            hint: nil,
            additionalScopes: ["https://www.googleapis.com/auth/gmail.readonly"]
        ) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Full error details: \(error)")
                    print("Error code: \((error as NSError).code)")
                    print("Error domain: \((error as NSError).domain)")
                    print("Error userInfo: \((error as NSError).userInfo)")
                    
                    completion(.failure(.gmailError(message: "There was a problem connecting to the Gmail service: \(error.localizedDescription)")))
                    return
                }
                
                guard let result = result else {
                    print("Sign-in result was nil")
                    completion(.failure(.gmailError(message: "Sign-in result was nil")))
                    return
                }
                
                guard let serverAuthCode = result.serverAuthCode else {
                    print("Failed to get authorization code. Check GIDServerClientID configuration.")
                    completion(.failure(.gmailError(message: "Failed to get authorization code. Check GIDServerClientID configuration.")))
                    return
                }
                
                guard let email = result.user.profile?.email else {
                    print("Failed to get email. Check GIDServerClientID configuration.")
                    completion(.failure(.gmailError(message: "Failed to get email. Check GIDServerClientID configuration.")))
                    return
                }
                
                let model = GmailAuthRequest(authCode: serverAuthCode, email: email)
                completion(.success(model))
            }
        }
        
        /*
         THIS IS THE OLDER IMPLEMENTATION
        let config = GIDConfiguration(clientID: iOSClientID, serverClientID: webClientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(
            withPresenting: presentingViewController,
            hint: nil,
            additionalScopes: ["https://www.googleapis.com/auth/gmail.readonly"]
        ) { result, error in
            if let error = error {
                print("Full error details: \(error)")
                print("Error code: \((error as NSError).code)")
                print("Error domain: \((error as NSError).domain)")
                print("Error userInfo: \((error as NSError).userInfo)")
                
                completion(.failure(.gmailError(message: "There was a problem connecting to the Gmail service: \(error.localizedDescription)")))
                return
            }
            
            print(result?.user.profile?.email)
            print(result?.user.profile?.name)
            print(result?.serverAuthCode)
            
            guard let user = result?.user, let serverAuthCode = result?.serverAuthCode, let email = user.profile?.email else {
                completion(.failure(.gmailError(message: "Missing auth code or email from Gmail response.")))
                return
            }
            
            let model = GmailAuthRequest(authCode: serverAuthCode, email: email)
            completion(.success(model))
        }
         */
    }
    
    private func clearWebKitData(completion: @escaping () -> Void) {
        print("🌐 Clearing Safari/WebKit data...")
        
        let dataStore = WKWebsiteDataStore.default()
        
        // Get all website data types
        let dataTypes = WKWebsiteDataStore.allWebsiteDataTypes()
        
        // Clear all website data from all time
        dataStore.removeData(ofTypes: dataTypes, modifiedSince: .distantPast) {
            print("✅ Cleared all WebKit website data")
            
            // Also clear HTTP cookies specifically
            self.clearHTTPCookies()
            
            completion()
        }
    }
    
    private func clearHTTPCookies() {
        print("🍪 Clearing HTTP cookies...")
        
        // Clear shared HTTP cookie storage
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
            print("✅ Cleared \(cookies.count) HTTP cookies")
        }
        
        // Clear cookies from distant past
        HTTPCookieStorage.shared.removeCookies(since: .distantPast)
        print("✅ Cleared all historical cookies")
    }
    
    private func clearAuthUserDefaults() {
        print("Clearing auth-related UserDefaults...")
        
        // Clear common GoogleSignIn UserDefaults keys
        let defaults = UserDefaults.standard
        let googleKeys = [
            "com.google.GIDSignIn",
            "GoogleSignIn",
            "GIDSignIn",
            "google_signin_configuration",
            "com.google.gid.client_id"
        ]
        
        for key in googleKeys {
            defaults.removeObject(forKey: key)
        }
        
        defaults.synchronize()
        print("Cleared UserDefaults")
    }
    
    private func clearAllKeychainEntries() {
        print("Clearing all keychain entries...")
                
        // Clear all keychain classes that could contain auth data
        let secItemClasses = [
            kSecClassGenericPassword,
            kSecClassInternetPassword,
            kSecClassCertificate,
            kSecClassKey,
            kSecClassIdentity
        ]
        
        for secItemClass in secItemClasses {
            // Clear both regular and iCloud sync keychain entries
            let queries: [(query: CFDictionary, description: String)] = [
                // Regular keychain entries
                (
                    query: [kSecClass: secItemClass] as CFDictionary,
                    description: "\(secItemClass)"
                ),
                
                // iCloud synced keychain entries
                (
                    query: [
                        kSecClass: secItemClass,
                        kSecAttrSynchronizable: kSecAttrSynchronizableAny,
                    ] as CFDictionary,
                    description: "\(secItemClass) (sync)"
                )
            ]
            
            for queryInfo in queries {
                let status = SecItemDelete(queryInfo.query)
                
                switch status {
                case errSecSuccess:
                    print("✅ Cleared \(queryInfo.description)")
                case errSecItemNotFound:
                    print("ℹ️ No items found for \(queryInfo.description)")
                default:
                    print("⚠️ Status \(status) for \(queryInfo.description)")
                }
            }
        }
    }
}
