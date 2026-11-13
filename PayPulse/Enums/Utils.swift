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
    
    /// Truncates a string to maxLength, appending "..." after the cutoff if it exceeds that length
    static func truncate(_ text: String, maxLength: Int) -> String {
        guard text.count > maxLength else { return text }
        return "\(text.prefix(maxLength))..."
    }

    /// Truncates an invoice ID to a fixed number of characters after its "retail_invoice_"/"rental_invoice_"
    /// prefix (if present), falling back to a flat character-count truncation otherwise
    static func truncateInvoiceID(_ text: String, charsAfterPrefix: Int = 8, fallbackMaxLength: Int = 25) -> String {
        let knownPrefixes = ["retail_invoice_", "rental_invoice_"]

        for prefix in knownPrefixes {
            if text.lowercased().hasPrefix(prefix) {
                guard text.count > prefix.count + charsAfterPrefix else { return text }
                return "\(text.prefix(prefix.count + charsAfterPrefix))..."
            }
        }

        return truncate(text, maxLength: fallbackMaxLength)
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
            // the access token has expired - show alert to user
            authManager.handleTokenExpiration()
        } else {
            // some other error - present error message in toast
            apiSpecificErrorHandling()
        }
    }

    // MARK: - Currency Utilities

    /// Maps currency symbols or codes to proper ISO currency codes
    static func mapCurrencyToCode(_ currencyInput: String) -> String {
        switch currencyInput.uppercased() {
        case "$", "USD":
            return "USD"
        case "€", "EUR":
            return "EUR"
        case "£", "GBP":
            return "GBP"
        case "¥", "JPY":
            return "JPY"
        case "SEK", "KR":
            return "SEK"
        case "NOK":
            return "NOK"
        case "DKK":
            return "DKK"
        default:
            // Default to SEK if currency is unrecognized
            return "SEK"
        }
    }

    /// Returns the appropriate locale for currency formatting
    static func getLocaleForCurrency(_ currencyCode: String) -> Locale {
        switch currencyCode {
        case "USD":
            return Locale(identifier: "en_US")
        case "EUR":
            return Locale(identifier: "de_DE") // German formatting for EUR (6,51 €)
        case "GBP":
            return Locale(identifier: "en_GB")
        case "JPY":
            return Locale(identifier: "ja_JP")
        case "SEK":
            return Locale(identifier: "sv_SE")
        case "NOK":
            return Locale(identifier: "nb_NO")
        case "DKK":
            return Locale(identifier: "da_DK")
        default:
            // Default to Swedish locale for unknown currencies
            return Locale(identifier: "sv_SE")
        }
    }

    /// Formats a currency amount using proper currency formatting with locale awareness
    static func formatCurrency(_ amount: Double, currency: String) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency

        // Map currency symbols/codes to proper ISO currency codes and locales
        let currencyCode = mapCurrencyToCode(currency)
        let locale = getLocaleForCurrency(currencyCode)

        numberFormatter.currencyCode = currencyCode
        numberFormatter.locale = locale

        let isWholeNumber = amount.truncatingRemainder(dividingBy: 1) == 0
        numberFormatter.minimumFractionDigits = isWholeNumber ? 0 : 2
        numberFormatter.maximumFractionDigits = isWholeNumber ? 0 : 2

        if let formattedAmount = numberFormatter.string(from: NSNumber(value: amount)) {
            return formattedAmount
        }

        // If NumberFormatter fails, use a consistent fallback
        return "\(currency) \(String(format: "%.2f", amount))"
    }
}
