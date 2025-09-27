//
//  Utils.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-07-01.
//

import SwiftUI
import Foundation
import Toasts

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
    
    static func hasDueDateExpired(_ dateString: String) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let date = formatter.date(from: dateString) else {
            // invalid format of date
            return false
        }
        
        return Date() > date
    }
    
    static func getCurrentYear() -> Int {
        let calender = Calendar.current
        let year = calender.component(.year, from: Date())
        return year
    }
    
    static func getIconColored(colorScheme: ColorScheme, iconName: String) -> Image {
        // This function returns the light or dark icon SVG depending upon the color scheme
        switch colorScheme {
        case .light:
            return Image("\(iconName)-dark")
        case .dark:
            return Image("\(iconName)-light")
        @unknown default:
            return Image("\(iconName)-light")
        }
    }
    
    static func handleAPITokenExpiration(_ apiError: APIError, authManager: AuthManager, apiSpecificErrorHandling: () -> Void) {
        if case .backendError(let code, _) = apiError, code == .tokenExpired {
            // the access token has expired - log the user out
            let toastValue = ToastValue(
                icon: Icon(name: "circle-x"),
                message: "Token expired - please log in again."
            )
            authManager.setPendingToast(toastValue)
            authManager.logout()
        } else {
            // some other error - present error message in toast
            apiSpecificErrorHandling()
        }
    }
}
