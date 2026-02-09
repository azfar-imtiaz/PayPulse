//
//  ClothingDetail.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-02-09.
//

import Foundation

struct ClothingDetail: RetailInvoiceDetail, Hashable {
    let invoiceID: String
    let tax: Double
    let deliveryFee: Double
    let paymentMethod: String?
    let items: [ClothingItem]

    enum CodingKeys: String, CodingKey {
        case invoiceID = "InvoiceID"
        case tax
        case deliveryFee = "delivery_fee"
        case paymentMethod = "payment_method"
        case items
    }

    // MARK: - Clothing Item

    struct ClothingItem: Codable, Hashable {
        let name: String
        let quantity: Int
        let brand: String
        let price: Double

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

    /// Returns total after applying tax and delivery fee
    func getTotal() -> Double {
        return getSubtotal() + tax + deliveryFee
    }

    /// Returns formatted payment method or "Not specified" if nil
    func getFormattedPaymentMethod() -> String {
        return paymentMethod ?? "Not specified"
    }
}