//
//  InvoiceResponseModel.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-06-30.
//

import OrderedCollections

struct InvoiceResponseModel: Codable {
    let invoiceCount: Int
    let invoices: [Int: [InvoiceModel]]
}
