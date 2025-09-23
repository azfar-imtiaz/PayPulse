//
//  AuthModels.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-06-29.
//

import Foundation

// MARK: - Authentication Request models

struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct SignupRequest: Encodable {
    let name: String
    let email: String
    let password: String
    
    private enum CodingKeys: String, CodingKey {
        case name
        case email
        case password
    }
}

struct GmailAuthRequest: Codable {
    let accessToken   : String
    let refreshToken  : String
    let username      : String
    let userEmail     : String
    let grantedScopes : [String]
    let tokenType     : String
    let expiresIn     : Int
    let clientInfo    : [String: String]
    
    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case username
        case userEmail = "email"
        case grantedScopes = "scope"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case clientInfo = "client_info"
    }
    /*
    let authCode : String
    let email    : String
     */
}

// MARK: - Authentication Response models

struct AuthResponse: Decodable {
    let username: String
    let accessToken: String
    let tokenType: String
    
    private enum CodingKeys: String, CodingKey {
        case username
        case accessToken = "access_token"
        case tokenType = "token_type"
    }
}

struct GmailResponseModel: Decodable {
    let googleEmail: String
    let scope: String
    let accountSwitch: Bool
    let consistencyMessage: String
    
    private enum CodingKeys: String, CodingKey {
        case googleEmail = "google_email"
        case scope
        case accountSwitch = "account_switch"
        case consistencyMessage = "message"
    }
}
