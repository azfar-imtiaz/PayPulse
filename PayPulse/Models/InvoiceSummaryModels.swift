//
//  InvoiceSummaryModels.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2026-11-09.
//

import Foundation

// MARK: - Invoice Summary Item (shared card shape for summary + recent endpoints)

struct InvoiceSummaryItem: Codable, Identifiable, Hashable {
    let invoiceType: InvoiceType
    let invoiceID: String
    let subType: String?
    let vendorName: String?
    let totalAmount: Double
    let currency: String?
    let invoiceDate: String

    var id: String { invoiceID }

    enum CodingKeys: String, CodingKey {
        case invoiceType = "invoice_type"
        case invoiceID = "invoice_id"
        case subType = "sub_type"
        case vendorName = "vendor_name"
        case totalAmount = "total_amount"
        case currency
        case invoiceDate = "invoice_date"
    }

    /// Reformats invoice_date (yyyy-MM-dd) into the dd-MM-yyyy format used elsewhere in the app
    func getFormattedDueDate() -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")

        guard let date = inputFormatter.date(from: invoiceDate) else {
            return invoiceDate
        }

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd-MM-yyyy"
        outputFormatter.locale = Locale(identifier: "en_US_POSIX")
        return outputFormatter.string(from: date)
    }
}

// MARK: - Retail Month Summary

struct RetailMonthSummary: Codable {
    let totalAmount: Double
    let currency: String?
    let count: Int
    let bySubtype: [String: Double]
    let items: [InvoiceSummaryItem]?

    enum CodingKeys: String, CodingKey {
        case totalAmount = "total_amount"
        case currency
        case count
        case bySubtype = "by_subtype"
        case items
    }
}

// MARK: - Invoice Summary Response

struct InvoiceSummaryResponse: Codable {
    let month: String
    let rental: InvoiceSummaryItem?
    let retail: RetailMonthSummary
}

// MARK: - Recent Invoices Response

struct RecentInvoicesResponse: Codable {
    let invoiceCount: Int
    let invoices: [InvoiceSummaryItem]
}
