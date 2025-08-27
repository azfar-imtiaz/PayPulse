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
    @Published var successMessage: String?
    
    private let userService: UserService
    private static let logger = Logger(subsystem: "PayPulse", category: "UserViewModel")
    
    init(userService: UserService) {
        self.userService = userService
    }
    
    func getUserInfo() async throws {
        self.errorMessage = nil
        
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
            Self.logger.error("(getUserInfo): The following error occurred: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func deleteUser(authManager: AuthManager) async throws {
        errorMessage = nil
        
        do {
            let responseCode = try await userService.deleteUser()
            if responseCode == 200 {
                successMessage = "User account deleted successfully!"
                Self.logger.info("(deleteUser): User account deleted successfully! Logging the user out...")
                authManager.logout()
            } else {
                errorMessage = "Failed to delete user account."
                Self.logger.error("(deleteUser): Failed to delete user account with \(responseCode) error code.")
            }
        } catch (let error) {
            self.errorMessage = (error as? APIError)?.localizedDescription ?? error.localizedDescription
            Self.logger.error("(deleteUser): The following error occurred: \(error.localizedDescription)")
        }
    }
}
