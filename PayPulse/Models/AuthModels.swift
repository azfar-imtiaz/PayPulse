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
    let gmailAppPassword: String
    
    private enum CodingKeys: String, CodingKey {
        case name
        case email
        case password
        case gmailAppPassword = "gmail_app_password"
    }
}

struct GmailAuthRequest: Codable {
    let authCode : String
    let email    : String
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
    let accountSwitch: String
    let consistencyMessage: String
    
    private enum CodingKeys: String, CodingKey {
        case googleEmail = "google_email"
        case scope
        case accountSwitch = "account_switch"
        case consistencyMessage = "consistency_message"
    }
}
