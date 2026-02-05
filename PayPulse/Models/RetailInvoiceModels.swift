//
//  RetailInvoiceModels.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-02-05.
//

import Foundation

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
            return "fork.knife"
        case .clothing:
            return "tshirt.fill"
        case .technology:
            return "laptopcomputer"
        case .subscriptions:
            return "arrow.clockwise.circle"
        case .grocery:
            return "cart.fill"
        case .utility:
            return "lightbulb.fill"
        case .miscellaneous:
            return "ellipsis.circle"
        case .travel:
            return "airplane"
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
    let currency: String
    let vendorName: String
    let subType: RetailInvoiceSubType
    
    var id: String { invoiceID }
    
    enum CodingKeys: String, CodingKey {
        case invoiceID = "InvoiceID"
        case invoiceDate = "invoice_date"
        case totalAmount = "total_amount"
        case currency
        case vendorName = "vendor_name"
        case subType = "sub_type"
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
        numberFormatter.currencyCode = currency
        
        if let formattedAmount = numberFormatter.string(from: NSNumber(value: totalAmount)) {
            return formattedAmount
        }
        
        return "\(currency) \(totalAmount)"
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

// MARK: - Retail Invoice Detail Response Model

struct RetailInvoiceDetailResponse: Codable {
    let invoiceDetails: [String: AnyCodable]
    
    enum CodingKeys: String, CodingKey {
        case invoiceDetails
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
