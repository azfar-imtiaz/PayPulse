//
//  GmailAuthService.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-09-01.
//

import Foundation
import GoogleSignIn

class GmailAuthService {
    private let iOSClientID : String = "623709424238-bggrm8506j6fqc845ee862cv9jiqi60a.apps.googleusercontent.com"
    private let gmailScopes = ["https://www.googleapis.com/auth/gmail.readonly"]
    
    init() {
        configureGoogleSignIn()
    }
    
    func configureGoogleSignIn() {
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: iOSClientID)
    }
    
    func signInForGmailAccess(presentingViewController: UIViewController, completion: @escaping (Result<GmailAuthRequest, APIError>) -> Void) {
        
        GIDSignIn.sharedInstance.disconnect() { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Disconnect error (may be normal): \(error.localizedDescription)")
                }
                
                self?.performSignIn(presentingViewController: presentingViewController, completion: completion)
            }
        }
    }
    
    private func performSignIn(presentingViewController: UIViewController, completion: @escaping (Result<GmailAuthRequest, APIError>) -> Void) {
        
        GIDSignIn.sharedInstance.signIn(
            withPresenting: presentingViewController,
            hint: nil,
            additionalScopes: gmailScopes
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
                
                self?.handleSuccessfulSignIn(result: result, completion: completion)
                
                /*
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
                 */
            }
        }
    }
    
    private func handleSuccessfulSignIn(result: GIDSignInResult, completion: @escaping (Result<GmailAuthRequest, APIError>) -> Void) {
        let user = result.user
        
        let accessToken = user.accessToken.tokenString
        let refreshToken = user.refreshToken.tokenString
        
        let userEmail = user.profile?.email ?? ""
        let username = user.profile?.name ?? ""
        let grantedScopes = user.grantedScopes ?? []
        
        print("Access token: \(String(accessToken.prefix(20)))...")
        print("Refresh token: \(String(refreshToken.prefix(20)))...")
        print("User: \(username) (\(userEmail))")
        print("Granted scopes: \(grantedScopes)")
        
        let model = GmailAuthRequest(
            accessToken: accessToken,
            refreshToken: refreshToken,
            username: username,
            userEmail: userEmail,
            grantedScopes: grantedScopes,
            tokenType: "Bearer",
            expiresIn: 3600,
            clientInfo: [
                "platform": "iOS",
                "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown",
                "timestamp": ISO8601DateFormatter().string(from: Date())
            ]
        )
        completion(.success(model))
    }
}
