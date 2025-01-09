//
//  InvoiceViewModel.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2024-11-21.
//

import Foundation

class InvoiceViewModel: ObservableObject {
    @Published var errorMsg: String? = nil
    @Published var invoices : [Invoice] = []
    var invoicesByYear      : [Int: [Invoice]] = [:]
    var latestInvoice       : Invoice?
    
    private let dynamoDBService = DynamoDBService()
    
    func fetchInvoices() {
        // fetch all invoices - these are already sorted
        dynamoDBService.fetchInvoices { [weak self] invoices, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMsg = error.localizedDescription
                    print(error.localizedDescription)
                } else {
                    self?.invoices = invoices ?? []
                    
                    if let allInvoices = invoices, allInvoices.count > 1 {
                        // get latest invoice
                        self!.latestInvoice = allInvoices.first
                        
                        // split invoices by a year into a dictionary
                        var invoicesForYearlySections = invoices
                        if let latest = self!.latestInvoice, latest.isCurrentMonthInvoice() {
                            invoicesForYearlySections = Array(allInvoices.dropFirst())
                        }
                        
                        self!.invoicesByYear = Dictionary(grouping: invoicesForYearlySections!) { invoice in
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "dd-MM-yyyy"
                            guard let dueDate = dateFormatter.date(from: invoice.dueDate) else { return 0 }
                            return Calendar.current.component(.year, from: dueDate)
                        }
                    }
                }
            }
        }
        
        
    }
    
    func getCurrentMonthNameAndYear() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        return dateFormatter.string(from: Date())
    }
    
    func getInvoicesByYearSorted() -> [[Int: [Invoice]].Keys.Element] {
        return self.invoicesByYear.keys.sorted() { $0 > $1 }
    }
}
