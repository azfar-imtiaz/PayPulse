//
//  MiscellaneousDetail.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-02-08.
//

import Foundation

// MARK: - Miscellaneous Invoice Detail

/// Detail fields for miscellaneous invoices.
/// Returned when calling: GET /v1/invoices/retail?subtype=miscellaneous&invoice-id={id}
/// Note: Base fields (vendor_name, total_amount, etc.) are NOT included in this response
struct MiscellaneousDetail: RetailInvoiceDetail, Hashable {
    let invoiceID: String
    let deliveryFee: Double?
    let notes: String?
    let tax: Double
    let category: String?
    let description: String?
    let items: [MiscellaneousItem]

    enum CodingKeys: String, CodingKey {
        case invoiceID = "InvoiceID"
        case deliveryFee = "delivery_fee"
        case notes
        case tax
        case category
        case description
        case items
    }

    // MARK: - Miscellaneous Item

    struct MiscellaneousItem: Codable, Hashable {
        let name: String
        let price: Double
        let quantity: Double

        /// Returns formatted price with quantity
        func getFormattedPrice() -> String {
            // Format quantity to remove unnecessary decimals (1.0 -> "1", 1.5 -> "1.5")
            let quantityString = quantity.truncatingRemainder(dividingBy: 1) == 0
                ? String(format: "%.0f", quantity)
                : String(format: "%.1f", quantity)
            return "\(quantityString) × \(price)"
        }

        /// Returns total price for this item
        func getTotalPrice() -> Double {
            return price * quantity
        }
    }

    // MARK: - Computed Properties

    /// Returns the subtotal before delivery fee and tax
    func getSubtotal() -> Double {
        return items.reduce(0.0) { $0 + $1.getTotalPrice() }
    }

    /// Returns total after applying delivery fee and tax
    func getTotal() -> Double {
        return getSubtotal() + (deliveryFee ?? 0.0) + tax
    }

    /// Returns formatted delivery fee
    func getFormattedDeliveryFee() -> String {
        return String(format: "%.2f", deliveryFee ?? 0.0)
    }

    /// Returns formatted tax
    func getFormattedTax() -> String {
        return String(format: "%.2f", tax)
    }

    /// Returns formatted subtotal
    func getFormattedSubtotal() -> String {
        return String(format: "%.2f", getSubtotal())
    }

    /// Returns formatted total
    func getFormattedTotal() -> String {
        return String(format: "%.2f", getTotal())
    }
}