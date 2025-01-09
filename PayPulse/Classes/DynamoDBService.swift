//
//  DynamoDBService.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2024-11-21.
//

import Foundation
import AWSDynamoDB

class DynamoDBService {
    private let dynamoDB = AWSDynamoDB.default()
    
    func fetchInvoices(completion: @escaping ([Invoice]?, Error?) -> Void) {
        let scanRequest = AWSDynamoDBScanInput()
        scanRequest?.tableName = "Wallenstam-Invoices"
        
        if let scanRequest = scanRequest {
            dynamoDB.scan(scanRequest) {
                result,
                error in
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                if let items = result?.items {
                    let invoices = items.compactMap { item -> Invoice? in
                        guard let id = item["InvoiceID"]?.s,
                              let dueDate = item["Due Date"]?.s,
                              let ocr = item["OCR"]?.s,
                              let filename = item["Filename"]?.s,
                              let hyra = item["Hyra"]?.s,
                              // let moms = item["Moms"]?.s,
                              let totalAmount = item["Total Amount"]?.s
                        else {
                            return nil
                        }
                        
                        let el = Int(item["El"]?.s ?? "0")
                        let kallvatten = Int(item["Kallvatten"]?.s ?? "0")
                        let varmvatten = Int(item["Varmvatten"]?.s ?? "0")
                        let mervärdesskatt = Int(item["Mervärdesskatt 25%"]?.s ?? "0")
                        let moms_amount = Int(item["Moms"]?.s ?? "0")
                        
                        let monthYear = Invoice.convertDateToMonthYear(from: dueDate)
                        
                        return Invoice(
                            id: id,
                            dueDate: dueDate,
                            dueDateMonthYear: monthYear ?? dueDate,
                            ocr_reference: ocr,
                            filename: filename,
                            electricity_amount: el!,
                            hyra_amount: hyra,
                            kallvatten_amount: kallvatten!,
                            varmvatten_amount: varmvatten!,
                            mervärdesskatt_amount: mervärdesskatt!,
                            moms_amount: moms_amount!,
                            totalAmount: totalAmount
                        )
                    }
                    
                    // sort the invoices in descending order
                    let sortedInvoices = self.sortInvoicesByDateDescending(invoices)
                    
                    completion(sortedInvoices, nil)
                } else {
                    completion([], nil)
                }
            }
        }
    }
    
    func sortInvoicesByDateDescending(_ invoices: [Invoice]) -> [Invoice] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        return invoices.sorted { first, second in
            guard let firstDate = dateFormatter.date(from: first.dueDate),
                  let secondDate = dateFormatter.date(from: second.dueDate) else {
                return false
            }
            
            return firstDate > secondDate
        }
    }
}
