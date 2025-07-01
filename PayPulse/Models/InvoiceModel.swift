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
    let hyra: Int
    let el: Int
    let kallvatten: Int
    let varmvatten: Int
    let totalAmount: Int
    let dueDateMonth: String
    let dueDateYear: String
    let dueDate: String
    let moms: Int
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
    
    func isDueInCurrentMonth() -> Bool {
        let currentCalendar = Calendar.current
        let currentMonth = currentCalendar.component(.month, from: Date())
        let currentYear  = currentCalendar.component(.year, from: Date())
        
        return currentMonth == Int(self.dueDateMonth) && currentYear == Int(self.dueDateYear)
    }
    
    func getDueMonthName() -> String {
        let dueMonth = Int(self.dueDateMonth)
        switch dueMonth {
        case 1:
            return "Jan"
        case 2:
            return "Feb"
        case 3:
            return "Mar"
        case 4:
            return "Apr"
        case 5:
            return "May"
        case 6:
            return "Jun"
        case 7:
            return "Jul"
        case 8:
            return "Aug"
        case 9:
            return "Sep"
        case 10:
            return "Oct"
        case 11:
            return "Nov"
        case 12:
            return "Dec"
        default:
            return "Unknown"
        }
    }
}

struct InvoiceCountModel: Codable {
    let invoiceCount: Int
}
