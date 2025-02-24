//
//  Invoice.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2024-11-21.
//

import Foundation

struct Invoice: Identifiable {
    let id: String
    let dueDate: String
    let dueDateMonthYear: String
    let ocr_reference: String
    let filename: String
    let electricity_amount: Int
    let hyra_amount: Int
    let kallvatten_amount: Int
    let varmvatten_amount: Int
    let mervärdesskatt_amount: Int
    let moms_amount: Int
    let totalAmount: Int
    
    let dateFormatter: DateFormatter = DateFormatter()
    
    init(id: String, dueDate: String, dueDateMonthYear: String, ocr_reference: String, filename: String, electricity_amount: Int, hyra_amount: String, kallvatten_amount: Int, varmvatten_amount: Int, mervärdesskatt_amount: Int, moms_amount: Int, totalAmount: String) {
        self.id = id
        self.dueDate = dueDate
        self.dueDateMonthYear = dueDateMonthYear
        self.ocr_reference = ocr_reference
        self.filename = filename
        self.electricity_amount = electricity_amount
        self.hyra_amount = Int(hyra_amount.replacingOccurrences(of: ",", with: "")) ?? -1
        self.kallvatten_amount = kallvatten_amount
        self.varmvatten_amount = varmvatten_amount
        self.mervärdesskatt_amount = mervärdesskatt_amount
        self.moms_amount = moms_amount
        self.totalAmount = Int(totalAmount.replacingOccurrences(of: ",", with: "")) ?? -1
        
        self.dateFormatter.dateFormat = "dd-MM-yyyy"
    }
    
    static func convertDateToMonthYear(from dateString: String) -> String? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd-MM-yyyy"
        
        guard let date = inputFormatter.date(from: dateString) else {
            return nil
        }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMMM, yyyy"
        
        return outputFormatter.string(from: date)
    }
    
    func getInvoiceDueYear() -> Int {
        guard let dueDate = self.dateFormatter.date(from: self.dueDate) else {
            return -1
        }
        
        let currentCalender = Calendar.current
        let dueYear = currentCalender.component(.year, from: dueDate)
        
        return dueYear
    }
    
    func getInvoiceDueMonth() -> String? {
        guard let date = self.dateFormatter.date(from: self.dueDate) else {
            return nil
        }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMMM"
        
        return outputFormatter.string(from: date)
    }
    
    func isCurrentMonthInvoice() -> Bool {
        guard let dueDate = self.dateFormatter.date(from: self.dueDate) else {
            return false
        }
        
        let currentCalendar = Calendar.current
        let currentMonth = currentCalendar.component(.month, from: Date())
        let currentYear  = currentCalendar.component(.year, from: Date())
        let dueMonth     = currentCalendar.component(.month, from: dueDate)
        let dueYear      = currentCalendar.component(.year, from: dueDate)
        
        return currentMonth == dueMonth && currentYear == dueYear
    }
    
    static func getAmountFormatted(amount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.locale = Locale(identifier: "en_US")
        
        // TODO: Add further formatting to add comma before last three digits of amount
        let formattedString = formatter.string(from: NSNumber(value: amount)) ?? "-1"
        if formattedString.count == 5 {
            return String(formattedString.prefix(2) + "," + formattedString.dropFirst(2))
        } else if formattedString.count == 4 {
            return String(formattedString.prefix(1) + "," + formattedString.dropFirst(1))
        } else {
            return formattedString
        }
    }
}
