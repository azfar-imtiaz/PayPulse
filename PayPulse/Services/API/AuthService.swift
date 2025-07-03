//
//  AuthService.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-06-29.
//

import Foundation
import Alamofire
import OSLog

class AuthService {
    private let apiClient: PayPulseAPIClient
    private let authManager: any AuthManagerProtocol
    static let logger = Logger(subsystem: "PayPulse", category: "AuthService")
    
    init(apiClient: PayPulseAPIClient, authManager: any AuthManagerProtocol) {
        self.apiClient = apiClient
        self.authManager = authManager
        Self.logger.debug("Auth service initialized!")
    }
    
    func login(request: LoginRequest) async throws -> AuthResponse {
        let parameters = try request.asDictionary()
        
        Self.logger.debug("Making login request with parameters: \(parameters, privacy: .private)")
        let response: APISuccessResponse<AuthResponse> = try await apiClient.request(
            path: "/auth/login",
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default,
            attachBearerToken: false
        )
        
        Self.logger.debug("Response received!")
        
        guard let authData = response.data else {
            Self.logger.fault("Error: Login response data was empty, but expected authentication info.")
            throw APIError.decodingError(NSError(
                domain: "AuthService",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Login response data was empty, but expected authentication info."]
                )
            )
        }
        
        Self.logger.debug("Saving authentication data...")
        authManager.saveAuthenticationData(username: authData.username, accessToken: authData.accessToken, tokenType: authData.tokenType)
        
        Self.logger.debug("Login call successful!")
        return authData
    }
    
    func signup(request: SignupRequest) async throws -> AuthResponse {
        let parameters = try request.asDictionary()
        
        Self.logger.debug("Making signup request with parameters: \(parameters, privacy: .private)")
        let response: APISuccessResponse<AuthResponse> = try await apiClient.request(
            path: "/auth/signup",
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default,
            attachBearerToken: false
        )
        
        Self.logger.debug("Response received!")
        guard let authData = response.data else {
            Self.logger.fault("Error: Signup response data was empty, but expected authentication info.")
            throw APIError.decodingError(NSError(
                domain: "AuthService",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Signup response data was empty, but expected authentication info."]
                )
            )
        }
        
        Self.logger.debug("Saving authentication data...")
        authManager.saveAuthenticationData(username: authData.username, accessToken: authData.accessToken, tokenType: authData.tokenType)
        
        Self.logger.debug("Signup call successful!")
        return authData
    }
}
