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
    
    func getFilteredData(for parameter: ParameterType, year: Int?, from invoices: [Invoice]) -> [(String, Int)] {
        if let year = year {
            return invoices
                .filter { $0.getInvoiceDueYear() == year }
                .map { ($0.getInvoiceDueMonth()!, getValue(for: parameter, from: $0)) }
        } else {
            return invoices
                .reduce(into: [(String, Int)]()) { result, invoice in
                    let value = getValue(for: parameter, from: invoice)
//                    if let last = result.last, last.0 == "\(invoice.getInvoiceDueYear())" {
//                        // MARK: Why are we doing this?
//                        // Calculating average if there are multiple entries for a year
//                        result[result.count - 1] = (last.0, (last.1 + value) / 2)
//                    } else {
//                        result.append(("\(invoice.getInvoiceDueYear())", value))
//                    }
                    result.append(("\(invoice.getInvoiceDueYear())", value))
                }
        }
    }
    
    private func getValue(for parameter: ParameterType, from invoice: Invoice) -> Int {
        switch parameter {
        case .baseRent:
            return invoice.hyra_amount
        case .coldWater:
            return invoice.kallvatten_amount
        case .hotWater:
            return invoice.varmvatten_amount
        case .electricity:
            return invoice.electricity_amount
        case .totalRent:
            return invoice.totalAmount
        }
    }
}
