//
//  InvoiceType.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-02-05.
//

import Foundation

/// Represents the main categories of invoices in the PayPulse system
enum InvoiceType: String, Codable, CaseIterable {
    case rental = "rental"
    case retail = "retail"
    
    var displayName: String {
        switch self {
        case .rental:
            return "Rental"
        case .retail:
            return "Retail"
        }
    }
    
    var apiPath: String {
        return self.rawValue
    }
}
