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
        var apiResponse: APISuccessResponse<AuthResponse>?
        do {
            apiResponse = try await apiClient.request(
                path: "/auth/login",
                method: .post,
                parameters: parameters,
                encoding: JSONEncoding.default,
                attachBearerToken: false
            )
        } catch {
            if let apiError = error as? APIError {
                switch apiError {
                case .backendError(let code, let message):
                    Self.logger.fault("Backend error: \(code.rawValue), \(message)")
                    if code == .tokenExpired {
                        authManager.logout()
                    }
                case .decodingError(let error):
                    Self.logger.fault("Decoding error: \(error.localizedDescription)")
                case .invalidURL:
                    Self.logger.fault("Invalid URL! \(error.localizedDescription)")
                case .networkError(let error):
                    Self.logger.fault("Networking error! \(error.localizedDescription)")
                case .unknown(let error):
                    Self.logger.fault("An unknown error occurred: \(error.localizedDescription)")
                }
            }
        }
        
        Self.logger.debug("Response received!")
        
        guard let response = apiResponse, let authData = response.data else {
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
