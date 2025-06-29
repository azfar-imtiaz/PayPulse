//
//  InvoicesViewModel.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-06-29.
//

import Foundation

class InvoicesViewModel: ObservableObject {
    @Published var invoicesCount: InvoiceCountModel = InvoiceCountModel(invoiceCount: 0)
    @Published var invoices: [InvoiceModel] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let invoiceService: InvoiceService
    
    init(invoiceService: InvoiceService) {
        self.invoiceService = invoiceService
    }
    
    func ingestInvoices() async {
        isLoading = true
        errorMessage = nil
        
        do {
            self.invoicesCount = try await invoiceService.ingestInvoices(type: "rental")
        } catch {
            self.errorMessage = (error as? APIError)?.localizedDescription ?? error.localizedDescription
            print("Failed to ingest invoices: \(self.errorMessage ?? "Unknown error")")
        }
        isLoading = false
    }
    
    func getInvoices() async {
        isLoading = true
        errorMessage = nil
        
        do {
            self.invoices = try await invoiceService.getRentalInvoices(type: "rental")
        } catch {
            self.errorMessage = (error as? APIError)?.localizedDescription ?? error.localizedDescription
            print("Failed to get invoices: \(self.errorMessage ?? "Unknown error")")
        }
        isLoading = false
    }
}
