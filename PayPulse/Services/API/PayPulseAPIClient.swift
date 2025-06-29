//
//  PayPulseAPIClient.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-06-29.
//

import Foundation
import Alamofire

protocol APIClientProtocol {
    func request<T: Decodable>(
        path: String,
        method: HTTPMethod,
        parameters: Parameters?,
        encoding: ParameterEncoding,
        headers: HTTPHeaders?
    ) async throws -> APISuccessResponse<T>
}

class PayPulseAPIClient: APIClientProtocol {
    private let authManager: any AuthManagerProtocol
    private let session: Session
    
    private let baseURLString = "https://6volksdhtf.execute-api.eu-west-1.amazonaws.com"
    
    init(authManager: any AuthManagerProtocol) {
        self.authManager = authManager
        self.session = Session.default
    }
    
    func request<T: Decodable>(
        path: String,
        method: HTTPMethod,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders? = nil
    ) async throws -> APISuccessResponse<T> {
        guard let url = URL(string: baseURLString)?.appendingPathComponent(path) else {
            throw APIError.invalidURL
        }
        
        var commonHeaders = headers ?? HTTPHeaders()
        
        if encoding is JSONEncoding {
            commonHeaders["Content-Type"] = "application/json"
        }
        
        if let token = authManager.accessToken, !token.isEmpty {
            commonHeaders["Authorization"] = "\(authManager.tokenType ?? "Bearer") \(token)"
        }
        
        let dataTask = session.request(
            url,
            method: method,
            parameters: parameters,
            encoding: encoding,
            headers: commonHeaders
        )
            .serializingDecodable(APISuccessResponse<T>.self, decoder: JSONDecoder())
        
        let response = await dataTask.response
        
        switch response.result {
        case .success(let apiResponse):
            if let httpResponse = response.response, (200..<300).contains(httpResponse.statusCode) {
                return apiResponse
            } else {
                // This should never be triggered - it means the backend is throwing errors with 2xx response codes
                throw APIError.unknown(NSError(
                    domain: "PayPulseAPIClient",
                    code: response.response?.statusCode ?? 0,
                    userInfo: [NSLocalizedDescriptionKey: "Unexpected successful response status code or structure"])
                )
            }
        case .failure(let afError):
            let customError = APIError.fromAFError(afError, data: response.data)
            throw customError
        }
    }
}
