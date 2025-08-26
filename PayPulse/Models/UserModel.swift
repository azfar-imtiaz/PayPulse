//
//  UserModel.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-06-29.
//

import Foundation

struct UserModel: Codable {
    let name      : String
    let email     : String
    let createdOn : String
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case email = "email"
        case createdOn = "created_on"
    }
}
