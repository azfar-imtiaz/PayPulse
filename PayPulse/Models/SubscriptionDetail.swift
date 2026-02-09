//
//  SubscriptionDetail.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-02-09.
//

import Foundation

struct SubscriptionDetail: RetailInvoiceDetail, Hashable {
    let invoiceID: String
    let paymentMethod: String?
    let duration: String?
    let invoiceNumber: String?
    let receiptNumber: String?

    enum CodingKeys: String, CodingKey {
        case invoiceID = "InvoiceID"
        case paymentMethod = "payment_method"
        case duration
        case invoiceNumber = "invoice_number"
        case receiptNumber = "receipt_number"
    }

    /// Returns formatted payment method or "Not specified" if nil
    func getFormattedPaymentMethod() -> String {
        return paymentMethod ?? "Not specified"
    }

    /// Returns formatted duration or "Not specified" if nil
    func getFormattedDuration() -> String {
        return duration ?? "Not specified"
    }

    /// Returns formatted invoice number or "Not available" if nil
    func getFormattedInvoiceNumber() -> String {
        return invoiceNumber ?? "Not available"
    }

    /// Returns formatted receipt number or "Not available" if nil
    func getFormattedReceiptNumber() -> String {
        return receiptNumber ?? "Not available"
    }
}