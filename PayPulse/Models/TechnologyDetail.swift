//
//  TechnologyDetail.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-02-09.
//

import Foundation

struct TechnologyDetail: RetailInvoiceDetail, Hashable {
    let invoiceID: String
    let deliveryFee: Double
    let paymentMethod: String?
    let notes: String?
    let tax: Double
    let description: String?
    let items: [TechnologyItem]

    enum CodingKeys: String, CodingKey {
        case invoiceID = "InvoiceID"
        case deliveryFee = "delivery_fee"
        case paymentMethod = "payment_method"
        case notes
        case tax
        case description
        case items
    }

    // MARK: - Technology Item

    struct TechnologyItem: Codable, Hashable {
        let name: String
        let price: Double
        let quantity: Int

        /// Returns formatted price with quantity
        func getFormattedPrice() -> String {
            return "\(quantity) × \(price)"
        }

        /// Returns total price for this item
        func getTotalPrice() -> Double {
            return price * Double(quantity)
        }
    }

    // MARK: - Computed Properties

    /// Returns the subtotal before tax and delivery fee
    func getSubtotal() -> Double {
        return items.reduce(0.0) { $0 + $1.getTotalPrice() }
    }


    /// Returns formatted payment method or "Not specified" if nil
    func getFormattedPaymentMethod() -> String {
        return paymentMethod ?? "Not specified"
    }

    /// Returns formatted description or "No description" if nil
    func getFormattedDescription() -> String {
        return description ?? "No description"
    }

    /// Returns formatted notes or "No notes" if nil
    func getFormattedNotes() -> String {
        return notes ?? "No notes"
    }
}