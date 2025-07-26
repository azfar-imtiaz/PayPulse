//
//  CommonAPIModels.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-06-29.
//

import Foundation

// MARK: - API Success response structure

struct APISuccessResponse<T: Decodable>: Decodable {
    let message: String
    let code: Int
    let data: T?
}

struct EmptyData: Decodable {}


// MARK: - API Error response structure

enum PayPulseErrorCode: String, Decodable {
    case invalidCredentials = "INVALID_CREDENTIALS"
    case invalidToken = "INVALID_TOKEN"
    case tokenExpired = "TOKEN_EXPIRED"
    case userNotFound = "USER_NOT_FOUND"
    case userAlreadyExists = "USER_ALREADY_EXISTS"
    case jwtError = "JWT_ERROR"
    case invalidJson = "INVALID_JSON"
    case missingFields = "MISSING_FIELDS"
    case invoiceParseError = "INVOICE_PARSE_ERROR"
    case dependencyFailure = "DEPENDENCY_FAILURE"
    case internalServerError = "INTERNAL_SERVER_ERROR"
    // is this fallback required?
    case unknown = "UNKNOWN_ERROR"
    
    // handling the case where the raw string might not match
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawString = try container.decode(String.self)
        if let code = PayPulseErrorCode(rawValue: rawString) {
            self = code
        } else {
            self = .unknown
        }
    }
}

struct ErrorDetail: Decodable {
    let code: PayPulseErrorCode
    let message: String
}

struct APIErrorResponse: Decodable {
    let error: ErrorDetail
}
