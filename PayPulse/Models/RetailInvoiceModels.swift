//
//  RetailInvoiceModels.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-02-05.
//

import Foundation
import SwiftUI
import OrderedCollections

// MARK: - Retail Invoice Sub-Type Enum


enum RetailInvoiceSubType: String, Codable, CaseIterable {
    case foodDelivery = "food-delivery"
    case clothing = "clothing"
    case technology = "technology"
    case subscriptions = "subscriptions"
    case grocery = "grocery"
    case utility = "utility"
    case miscellaneous = "miscellaneous"
    case travel = "travel"
    
    var displayName: String {
        switch self {
        case .foodDelivery:
            return "Food Delivery"
        case .clothing:
            return "Clothing"
        case .technology:
            return "Technology"
        case .subscriptions:
            return "Subscriptions"
        case .grocery:
            return "Grocery"
        case .utility:
            return "Utility"
        case .miscellaneous:
            return "Miscellaneous"
        case .travel:
            return "Travel"
        }
    }
    
    var iconName: String {
        switch self {
        case .foodDelivery:
            return "food-delivery"
        case .clothing:
            return "clothing"
        case .technology:
            return "tech"
        case .subscriptions:
            return "subscriptions"
        case .grocery:
            return "grocery"
        case .utility:
            return "utility"
        case .miscellaneous:
            return "miscellaneous"
        case .travel:
            return "travel"
        }
    }
    
    var color: Color {
        switch self {
        case .foodDelivery:
            return Color(red: 1.0, green: 0.42, blue: 0.21) // #FF6B35
        case .clothing:
            return Color(red: 0.56, green: 0.27, blue: 0.68) // #8E44AD
        case .technology:
            return Color(red: 0.20, green: 0.60, blue: 0.86) // #3498DB
        case .subscriptions:
            return Color(red: 0.18, green: 0.80, blue: 0.44) // #2ECC71
        case .grocery:
            return Color(red: 0.15, green: 0.68, blue: 0.38) // #27AE60
        case .utility:
            return Color(red: 0.95, green: 0.61, blue: 0.07) // #F39C12
        case .miscellaneous:
            return Color(red: 0.58, green: 0.65, blue: 0.65) // #95A5A6
        case .travel:
            return Color(red: 0.91, green: 0.30, blue: 0.24) // #E74C3C
        }
    }

    var apiPath: String {
        return self.rawValue
    }
}

// MARK: - Retail Invoice Base Model

struct RetailInvoiceBase: Codable, Identifiable, Hashable {
    let invoiceID: String
    let invoiceDate: String
    let totalAmount: Double
    let currency: String?
    let vendorName: String

    var id: String { invoiceID }

    enum CodingKeys: String, CodingKey {
        case invoiceID = "InvoiceID"
        case invoiceDate = "invoice_date"
        case totalAmount = "total_amount"
        case currency
        case vendorName = "vendor_name"
    }

    /// Returns the currency or SEK as default if null
    var displayCurrency: String {
        return currency ?? "SEK"
    }
    
    /// Returns a formatted date string for display
    func getFormattedDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let date = dateFormatter.date(from: invoiceDate) {
            dateFormatter.dateFormat = "MMM d, yyyy"
            return dateFormatter.string(from: date)
        }
        
        return invoiceDate
    }
    
    /// Returns the month name from the invoice date
    func getMonthName() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let date = dateFormatter.date(from: invoiceDate) {
            dateFormatter.dateFormat = "MMM"
            return dateFormatter.string(from: date)
        }
        
        return "Unknown"
    }
    
    /// Returns the month number from the invoice date (1-12)
    func getMonthNumber() -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        if let date = dateFormatter.date(from: invoiceDate) {
            let calendar = Calendar.current
            return calendar.component(.month, from: date)
        }

        return 0
    }

    /// Returns the year from the invoice date
    func getYear() -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        if let date = dateFormatter.date(from: invoiceDate) {
            let calendar = Calendar.current
            return calendar.component(.year, from: date)
        }

        return 0
    }
    
    /// Formats the total amount with currency
    func getFormattedAmount() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency

        // Map common currency symbols/codes to proper ISO currency codes and locales
        let currencyCode = mapCurrencyToCode(displayCurrency)
        let locale = getLocaleForCurrency(currencyCode)

        numberFormatter.currencyCode = currencyCode
        numberFormatter.locale = locale

        if let formattedAmount = numberFormatter.string(from: NSNumber(value: totalAmount)) {
            return formattedAmount
        }

        // If NumberFormatter fails, use a consistent fallback with the display currency
        return "\(displayCurrency) \(String(format: "%.2f", totalAmount))"
    }

    /// Maps currency symbols or codes to proper ISO currency codes
    private func mapCurrencyToCode(_ currencyInput: String) -> String {
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
    private func getLocaleForCurrency(_ currencyCode: String) -> Locale {
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
}

// MARK: - Retail Invoice Detail Protocol

protocol RetailInvoiceDetail: Codable {
    var invoiceID: String { get }
}

// MARK: - Retail Invoice Response Model

struct RetailInvoiceResponse: Codable {
    let invoiceCount: Int
    let invoices: [String: [RetailInvoiceBase]]

    /// Returns invoices grouped by sub-type
    func getInvoicesBySubType() -> [RetailInvoiceSubType: [RetailInvoiceBase]] {
        var result: [RetailInvoiceSubType: [RetailInvoiceBase]] = [:]

        for (key, value) in invoices {
            if let subType = RetailInvoiceSubType(rawValue: key) {
                result[subType] = value
            }
        }

        return result
    }
}

// MARK: - Retail Invoice By Year Response Model

struct RetailInvoiceByYearResponse: Codable {
    let invoiceCount: Int
    let invoices: [String: [RetailInvoiceBase]]

    /// Converts string year keys to integer keys and returns ordered dictionary
    func getInvoicesByYear() -> OrderedDictionary<Int, [RetailInvoiceBase]> {
        var result: [Int: [RetailInvoiceBase]] = [:]

        for (yearString, invoicesList) in invoices {
            if let year = Int(yearString) {
                // Sort invoices by date (latest first) and then by month
                let sortedInvoices = invoicesList.sorted { first, second in
                    // First sort by month (latest first)
                    let firstMonth = first.getMonthNumber()
                    let secondMonth = second.getMonthNumber()

                    if firstMonth != secondMonth {
                        return firstMonth > secondMonth
                    }

                    // Then by date within the month
                    return first.invoiceDate > second.invoiceDate
                }

                result[year] = sortedInvoices
            }
        }

        // Sort years in descending order (latest first)
        return OrderedDictionary(uniqueKeysWithValues: result.sorted { $0.key > $1.key })
    }
}

// MARK: - Retail Invoice Detail Response Model

struct RetailInvoiceDetailResponse: Codable {
    let invoiceDetails: [String: AnyCodable]
    
    enum CodingKeys: String, CodingKey {
        case invoiceDetails
    }
}

// MARK: - Retail Invoice Counts Response Model

struct RetailInvoiceCountsResponse: Codable {
    private let foodDelivery: Int
    private let clothing: Int
    private let technology: Int
    private let subscriptions: Int
    private let grocery: Int
    private let utility: Int
    private let miscellaneous: Int
    private let travel: Int

    enum CodingKeys: String, CodingKey {
        case foodDelivery = "food-delivery"
        case clothing = "clothing"
        case technology = "technology"
        case subscriptions = "subscriptions"
        case grocery = "grocery"
        case utility = "utility"
        case miscellaneous = "miscellaneous"
        case travel = "travel"
    }

    /// Returns counts grouped by sub-type enum
    func getCountsBySubType() -> [RetailInvoiceSubType: Int] {
        return [
            .foodDelivery: foodDelivery,
            .clothing: clothing,
            .technology: technology,
            .subscriptions: subscriptions,
            .grocery: grocery,
            .utility: utility,
            .miscellaneous: miscellaneous,
            .travel: travel
        ]
    }

    /// Returns the total count across all sub-types
    func getTotalCount() -> Int {
        return foodDelivery + clothing + technology + subscriptions + grocery + utility + miscellaneous + travel
    }
}

// MARK: - AnyCodable Helper (for dynamic detail fields)

struct AnyCodable: Codable {
    let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let string = try? container.decode(String.self) {
            value = string
        } else if let array = try? container.decode([AnyCodable].self) {
            value = array.map { $0.value }
        } else if let dictionary = try? container.decode([String: AnyCodable].self) {
            value = dictionary.mapValues { $0.value }
        } else {
            value = NSNull()
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch value {
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let array as [Any]:
            try container.encode(array.map { AnyCodable($0) })
        case let dictionary as [String: Any]:
            try container.encode(dictionary.mapValues { AnyCodable($0) })
        default:
            try container.encodeNil()
        }
    }
}
