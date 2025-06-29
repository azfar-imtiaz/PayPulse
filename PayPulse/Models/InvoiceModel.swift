//
//  InvoiceModel.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-06-29.
//

import Foundation

struct InvoiceModel: Codable, Identifiable {
    let invoiceID: String
    let filename: String
    let hyra: String
    let el: String?
    let kallvatten: String?
    let varmvatten: String?
    let totalAmount: String
    let dueDateMonth: String
    let dueDateYear: String
    let dueDate: String
    let moms: String
    let ocr: String
    
    var id: String { invoiceID }
    
    enum CodingKeys: String, CodingKey {
        case invoiceID = "InvoiceID"
        case dueDateMonth = "due_date_month"
        case dueDateYear = "due_date_year"
        case dueDate = "Due Date"
        case hyra = "Hyra"
        case el = "El"
        case kallvatten = "Kallvatten"
        case varmvatten = "Varmvatten"
        case totalAmount = "Total Amount"
        case moms = "Moms"
        case ocr = "OCR"
        case filename = "Filename"
    }
}

struct InvoiceCountModel: Codable {
    let invoiceCount: Int
}
