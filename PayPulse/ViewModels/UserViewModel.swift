//
//  UserViewModel.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-08-26.
//

import Foundation
import OSLog

class UserViewModel: ObservableObject {
    @Published var username      : String = ""
    @Published var userEmail     : String = ""
    @Published var userCreatedOn : String = ""
    @Published var errorMessage  : String?
    
    private let userService: UserService
    private static let logger = Logger(subsystem: "PayPulse", category: "UserViewModel")
    
    init(userService: UserService) {
        self.userService = userService
    }
    
    func getUserInfo() async throws {
        errorMessage = nil
        
        do {
            if let userModel = try await userService.getUserInfo() {
                self.username = userModel.name
                self.userEmail = userModel.email
                self.userCreatedOn = userModel.createdOn
            } else {
                self.username = "Unknown"
                self.userEmail = "Unknown"
                self.userCreatedOn = "Unknown"
            }
        } catch(let error) {
            self.errorMessage = (error as? APIError)?.localizedDescription ?? error.localizedDescription
            Self.logger.error("The following error occurred: \(error.localizedDescription)")
        }
    }
}
