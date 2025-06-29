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
    
    func deleteUser() async throws -> String {
        let response: APISuccessResponse<EmptyData> = try await apiClient.request(
            path: "/delete/me",
            method: .delete
        )
        
        return response.message
    }
}
