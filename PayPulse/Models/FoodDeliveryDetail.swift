//
//  FoodDeliveryDetail.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-02-05.
//

import Foundation

// MARK: - Food Delivery Invoice Detail

/// Detail fields for food delivery invoices.
/// Returned when calling: GET /v1/invoices/retail?subtype=food-delivery&invoice-id={id}
/// Note: Base fields (vendor_name, total_amount, etc.) are NOT included in this response
struct FoodDeliveryDetail: RetailInvoiceDetail, Hashable {
    let invoiceID: String
    let deliveryFee: Double
    let items: [FoodItem]
    let discount: Double
    
    enum CodingKeys: String, CodingKey {
        case invoiceID = "InvoiceID"
        case deliveryFee = "delivery_fee"
        case items
        case discount
    }
    
    // MARK: - Food Item
    
    struct FoodItem: Codable, Hashable {
        let name: String
        let description: String?
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
    
    /// Returns the subtotal before delivery fee and discount
    func getSubtotal() -> Double {
        return items.reduce(0.0) { $0 + $1.getTotalPrice() }
    }
    
    /// Returns total after applying delivery fee and discount
    func getTotal() -> Double {
        return getSubtotal() + deliveryFee - discount
    }
    
    /// Returns formatted delivery fee
    func getFormattedDeliveryFee() -> String {
        return String(format: "%.2f", deliveryFee)
    }
    
    /// Returns formatted discount
    func getFormattedDiscount() -> String {
        return String(format: "%.2f", discount)
    }
}
