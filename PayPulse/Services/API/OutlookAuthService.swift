//
//  OutlookAuthService.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2026-10-22.
//

import Foundation
import AuthenticationServices
import CryptoKit

class OutlookAuthService: NSObject {
    private let clientID: String = "6861aa59-75ec-4dac-883e-0f9b96aa6576"
    // Sent to Microsoft as the redirect_uri for both /authorize and /token - must be a
    // Web-platform redirect URI, since the backend's confidential-client code exchange
    // (client_secret) is rejected by Microsoft on any Mobile/Desktop-platform redirect URI
    // (AADSTS90023). The bounce Lambda at this URL relays back to callbackURLScheme below,
    // which is what ASWebAuthenticationSession actually intercepts.
    private let redirectUri: String = "https://6volksdhtf.execute-api.eu-west-1.amazonaws.com/v1/auth/outlook/callback"
    private let callbackURLScheme: String = "msauth.com.azfarimtiaz.paypulse"
    private let authorizeEndpoint: String = "https://login.microsoftonline.com/common/oauth2/v2.0/authorize"
    private let outlookScopes = "User.Read Mail.Read offline_access openid email"

    private var webAuthSession: ASWebAuthenticationSession?
    private var presentationContextProvider: PresentationContextProvider?

    func signInForOutlookAccess(presentingViewController: UIViewController, completion: @escaping (Result<OutlookAuthRequest, APIError>) -> Void) {
        let codeVerifier = Self.generateCodeVerifier()
        let codeChallenge = Self.codeChallenge(for: codeVerifier)

        guard var components = URLComponents(string: authorizeEndpoint) else {
            completion(.failure(.outlookError(message: "Failed to construct Outlook authorize URL")))
            return
        }

        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "redirect_uri", value: redirectUri),
            URLQueryItem(name: "scope", value: outlookScopes),
            URLQueryItem(name: "code_challenge", value: codeChallenge),
            URLQueryItem(name: "code_challenge_method", value: "S256")
        ]

        guard let authURL = components.url else {
            completion(.failure(.outlookError(message: "Failed to construct Outlook authorize URL")))
            return
        }

        let contextProvider = PresentationContextProvider(presentingViewController: presentingViewController)
        self.presentationContextProvider = contextProvider

        let session = ASWebAuthenticationSession(url: authURL, callbackURLScheme: callbackURLScheme) { [weak self] callbackURL, error in
            DispatchQueue.main.async {
                defer { self?.webAuthSession = nil; self?.presentationContextProvider = nil }

                if let error = error {
                    print("Outlook sign-in error: \(error)")
                    completion(.failure(.outlookError(message: "There was a problem connecting to the Outlook service: \(error.localizedDescription)")))
                    return
                }

                guard let callbackURL = callbackURL,
                      let components = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false),
                      let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
                    print("Outlook sign-in callback missing authorization code")
                    completion(.failure(.outlookError(message: "Outlook sign-in did not return an authorization code")))
                    return
                }

                let model = OutlookAuthRequest(code: code, codeVerifier: codeVerifier)
                completion(.success(model))
            }
        }

        session.presentationContextProvider = contextProvider
        session.prefersEphemeralWebBrowserSession = true
        self.webAuthSession = session
        session.start()
    }

    // MARK: - PKCE

    private static func generateCodeVerifier() -> String {
        var buffer = [UInt8](repeating: 0, count: 32)
        _ = SecRandomCopyBytes(kSecRandomDefault, buffer.count, &buffer)
        return Data(buffer).base64URLEncodedString()
    }

    private static func codeChallenge(for verifier: String) -> String {
        let digest = SHA256.hash(data: Data(verifier.utf8))
        return Data(digest).base64URLEncodedString()
    }
}

private class PresentationContextProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
    weak var presentingViewController: UIViewController?

    init(presentingViewController: UIViewController) {
        self.presentingViewController = presentingViewController
    }

    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return presentingViewController?.view.window ?? ASPresentationAnchor()
    }
}

private extension Data {
    func base64URLEncodedString() -> String {
        base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
