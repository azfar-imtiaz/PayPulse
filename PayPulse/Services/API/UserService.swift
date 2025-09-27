//
//  UserService.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-06-29.
//

import Foundation

class UserService {
    private let apiClient: PayPulseAPIClient
    
    init(apiClient: PayPulseAPIClient) {
        self.apiClient = apiClient
    }
    
    func deleteUser() async throws -> Int {
        let response: APISuccessResponse<EmptyData> = try await apiClient.request(
            path: "/user/me",
            method: .delete
        )
        
        return response.code
    }
    
    func getUserInfo() async throws -> UserModel? {
        let response: APISuccessResponse<UserModel> = try await apiClient.request(
            path: "/user/me",
            method: .get
        )
        
        if let data = response.data {
            return data
        }
        
        return nil
    }
    
    func connectToGmail(gmailRequest: GmailAuthRequest) async throws -> GmailResponseModel {
        let parameters = try gmailRequest.asDictionary()
        
        let response: APISuccessResponse<GmailResponseModel> = try await apiClient.request(
            path: "/auth/gmail/store-tokens",
            method: .post,
            parameters: parameters
        )
        
        guard let data = response.data else {
            throw APIError.gmailError(message: "The following error occurred from Gmail Service: \(response.code): \(response.message)")
        }
        
        return data
    }
}
