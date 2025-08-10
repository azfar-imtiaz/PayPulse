//
//  PayPulseAPIClient.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-06-29.
//

import Foundation
import Alamofire
import OSLog

protocol APIClientProtocol {
    func request<T: Decodable>(
        path: String,
        method: HTTPMethod,
        parameters: Parameters?,
        encoding: ParameterEncoding,
        headers: HTTPHeaders?,
        attachBearerToken: Bool
    ) async throws -> APISuccessResponse<T>
}

class PayPulseAPIClient: APIClientProtocol {
    private let authManager: any AuthManagerProtocol
    private let session: Session
    private static let logger = Logger(subsystem: "PayPulse", category: "APIClient")
    
    private let version = "v1"
    
    private let baseURLString: String
    
    init(authManager: any AuthManagerProtocol) {
        self.authManager = authManager
        self.session = Session.default
        baseURLString = "https://6volksdhtf.execute-api.eu-west-1.amazonaws.com/\(version)"
        Self.logger.debug("API client initialized!")
    }
    
    func request<T: Decodable>(
        path: String,
        method: HTTPMethod,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders? = nil,
        attachBearerToken: Bool = true
    ) async throws -> APISuccessResponse<T> {
        guard let url = URL(string: baseURLString)?.appendingPathComponent(path) else {
            throw APIError.invalidURL
        }
        Self.logger.debug("(apiClient): Request validated.")
        
        var commonHeaders = headers ?? HTTPHeaders()
        
        if encoding is JSONEncoding {
            Self.logger.debug("(apiClient): Adding content-type header to request.")
            commonHeaders["Content-Type"] = "application/json"
        }
        
        if attachBearerToken {
            if let token = authManager.accessToken, !token.isEmpty {
                Self.logger.debug("(apiClient): Adding bearer token to request.")
                commonHeaders["Authorization"] = "\(authManager.tokenType ?? "Bearer") \(token)"
            }
        }
        
        Self.logger.debug("(apiClient): Making request...")
        let dataTask = session.request(
            url,
            method: method,
            parameters: parameters,
            encoding: encoding,
            headers: commonHeaders
        )
        .serializingDecodable(APISuccessResponse<T>.self, decoder: JSONDecoder())
        
        Self.logger.debug("(apiClient): Awaiting response...")
        let response = await dataTask.response
        
        Self.logger.debug("(apiClient): Response received!")
        
        let statusCode = response.response?.statusCode
        if statusCode == 204 {
            Self.logger.info("(apiClient): 204 response intercepted!")
            return APISuccessResponse<T>(
                message: "No content",
                code: 204,
                data: nil
            )
        }
        
        switch response.result {
        case .success(let apiResponse):
            if let httpResponse = response.response, (200..<300).contains(httpResponse.statusCode) {
                Self.logger.info("(apiClient): Request was successful! Received \(httpResponse.statusCode) code.")
                return apiResponse
            } else {
                // This should never be triggered - it means the backend is throwing errors with 2xx response codes
                Self.logger.error("(apiClient): Request failed with \(statusCode ?? -1) code.")
                throw APIError.unknown(NSError(
                    domain: "PayPulseAPIClient",
                    code: response.response?.statusCode ?? 0,
                    userInfo: [NSLocalizedDescriptionKey: "Unexpected successful response status code or structure"])
                )
            }
        case .failure(let afError):
            Self.logger.error("(apiClient): Request failed: \(afError.localizedDescription)")
            if afError.responseCode == 401 {
                throw APIError.backendError(code: .tokenExpired, message: "Token has expired - log in again!")
            }
            let customError = APIError.fromAFError(afError, data: response.data)
            throw customError
        }
    }
}
