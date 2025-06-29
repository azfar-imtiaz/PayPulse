//
//  APIError.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-06-29.
//

import Foundation
import Alamofire

enum APIError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    
    case backendError(code: PayPulseErrorCode, message: String)
    
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The request URL was invalid."
        case .networkError(let error):
            return "Network connection error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Failed to process server response. (Details: \(error.localizedDescription)"
        case .backendError(let code, let message):
            switch code {
            case .invalidCredentials: return "Invalid email or password. Please try again."
            case .tokenExpired: return "Your session has expired. Please log in again."
            case .invalidToken: return "Your session is invalid. Please log in again."
            case .userNotFound: return "No user with this account found."
            case .userAlreadyExists: return "An account with this email already exists."
            case .invoiceParseError: return "Failed to parse invoice data. Please try again."
            case .jwtError: return "Failed to generate or parse JWT token. Please try again."
            case .missingFields: return "Missing required fields. Please check your input."
            case .dependencyFailure: return "Failed to complete the request. Please try again."
            case .internalServerError: return "An internal server error occurred. Please try again later."
            default: return "Server error (\(code.rawValue)): \(message)"
            }
        case .unknown(let error):
            return "An unexpected error occurred: \(error.localizedDescription)"
        }
    }
    
    static func fromAFError(_ afError: AFError, data: Data?) -> APIError {
        // This function maps Alamofire's AFError to our APIError
        if let underlyingError = afError.underlyingError as? URLError {
            return .networkError(underlyingError)
        }
        
        if let data = data, let errorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
            let code = errorResponse.error.code
            let message = errorResponse.error.message
            return .backendError(code: code, message: message)
        } else if case let .responseSerializationFailed(reason) = afError,
                    case let .decodingFailed(decodingError) = reason {
            return .decodingError(decodingError)
        } else {
            let message = data.flatMap { String(data: $0, encoding: .utf8) }
            return .backendError(code: .unknown, message: message ?? "Unknown error.")
        }
    }
}
