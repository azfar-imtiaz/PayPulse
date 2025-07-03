//
//  InvoicesViewModel.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-06-29.
//

import Foundation
import OrderedCollections

@MainActor
class InvoicesViewModel: ObservableObject {
    @Published var invoiceIngestionCount : InvoiceCountModel = InvoiceCountModel(invoiceCount: 0)
    @Published var invoices              : OrderedDictionary<Int, [InvoiceModel]> = [:]
    @Published var latestInvoice         : InvoiceModel? = nil      // this is not being used anymore
    @Published var errorMessage          : String?
    
    private let invoiceService: InvoiceService
    
    init(invoiceService: InvoiceService) {
        self.invoiceService = invoiceService
    }
    
    func ingestInvoices() async {
        errorMessage = nil
        
        do {
            self.invoiceIngestionCount = try await invoiceService.ingestInvoices(type: "rental")
        } catch {
            self.errorMessage = (error as? APIError)?.localizedDescription ?? error.localizedDescription
            print("Failed to ingest invoices: \(self.errorMessage ?? "Unknown error")")
        }
    }
    
    func getInvoices() async throws {
        errorMessage = nil
        
        do {
            self.invoices = try await invoiceService.getRentalInvoices(type: "rental")
            if self.invoices.count > 0 {
                self.latestInvoice = getLatestInvoice(invoices: self.invoices)
            }
        } catch {
            self.errorMessage = (error as? APIError)?.localizedDescription ?? error.localizedDescription
            print("Failed to get invoices: \(self.errorMessage ?? "Unknown error")")
        }
    }
    
    func getLatestInvoice(invoices: OrderedDictionary<Int, [InvoiceModel]>) -> InvoiceModel? {
        if let latestYear = invoices.keys.max() {
            return invoices[latestYear]?.first
        }
        return nil
    }
    
    func getFilteredData(for parameter: ParameterType, selectedYear: Int?) -> [(String, Int)] {
        // This function filters the invoices on year as well as on the following properties: baseRent, coldWater, hotWater, electricity, and totalRent
        
        var result: [(String, Int)] = []
        
        let filteredInvoices: [InvoiceModel]
        if let year = selectedYear {
            filteredInvoices = invoices[year] ?? []
        } else {
            filteredInvoices = self.invoices.values.flatMap { $0 }
        }
        
        for invoice in filteredInvoices {
            let key: String
            if let _ = selectedYear {
                key = invoice.getDueMonthName()
            } else {
                key = invoice.dueDateYear
            }
            
            result.append((key, getValue(for: parameter, from: invoice)))
        }
        
        // Reversing here so that the years are ordered in the graph
        return result.reversed()
    }
    
    private func getValue(for parameter: ParameterType, from invoice: InvoiceModel) -> Int {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        switch parameter {
        case .baseRent:
            return invoice.hyra
        case .coldWater:
            return invoice.kallvatten
        case .hotWater:
            return invoice.varmvatten
        case .electricity:
            return invoice.el
        case .totalRent:
            return invoice.totalAmount
        }
    }
}
