//
//  Utils.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-07-01.
//

import Foundation

enum Utils {
    // Using enum instead of struct to prevent instantiation, since this will consist of static functions only
    static func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.locale = Locale(identifier: "en_US")
        
        // TODO: Add further formatting to add comma before last three digits of amount
        let formattedString = formatter.string(from: NSNumber(value: number)) ?? "-1"
        if formattedString.count == 5 {
            return String(formattedString.prefix(2) + "," + formattedString.dropFirst(2))
        } else if formattedString.count == 4 {
            return String(formattedString.prefix(1) + "," + formattedString.dropFirst(1))
        } else {
            return formattedString
        }
    }
}
