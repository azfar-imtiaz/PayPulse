//
//  AuthService.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-06-29.
//

import Foundation
import Alamofire

class AuthService {
    private let apiClient: PayPulseAPIClient
    private let authManager: any AuthManagerProtocol
    
    init(apiClient: PayPulseAPIClient, authManager: any AuthManagerProtocol) {
        self.apiClient = apiClient
        self.authManager = authManager
    }
    
    func login(request: LoginRequest) async throws -> AuthResponse {
        let parameters = try request.asDictionary()
        let response: APISuccessResponse<AuthResponse> = try await apiClient.request(
            path: "/auth/login",
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default
        )
        
        guard let authData = response.data else {
            throw APIError.decodingError(NSError(
                domain: "AuthService",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Login response data was empty, but expected authentication info."]
                )
            )
        }
        
        authManager.saveAuthenticationData(username: authData.username, accessToken: authData.accessToken, tokenType: authData.tokenType)
        return authData
    }
    
    func signup(request: SignupRequest) async throws -> AuthResponse {
        let parameters = try request.asDictionary()
        let response: APISuccessResponse<AuthResponse> = try await apiClient.request(
            path: "/auth/signup",
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default
        )
        
        guard let authData = response.data else {
            throw APIError.decodingError(NSError(
                domain: "AuthService",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Signup response data was empty, but expected authentication info."]
                )
            )
        }
        
        authManager.saveAuthenticationData(username: authData.username, accessToken: authData.accessToken, tokenType: authData.tokenType)
        return authData
    }
}
