//
//  InvoiceService.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-06-29.
//

import Foundation

class InvoiceService {
    private let apiClient: PayPulseAPIClient
    
    init(apiClient: PayPulseAPIClient) {
        self.apiClient = apiClient
    }
    
    func ingestInvoices(type: String) async throws -> InvoiceCountModel {
        let response: APISuccessResponse<InvoiceCountModel> = try await apiClient.request(
            path: "invoices/\(type)/ingest",
            method: .post,
            parameters: nil
        )
        
        // TODO: Is this needed?
        guard let invoiceCount = response.data else {
            return InvoiceCountModel(invoiceCount: 0)
        }
        
        return invoiceCount
    }
    
    func getRentalInvoices(type: String) async throws -> [InvoiceModel] {
        let response: APISuccessResponse<[InvoiceModel]> = try await apiClient.request(
            path: "invoices/\(type)",
            method: .get
        )
        
        guard let invoices = response.data else {
            return []
        }
        
        return invoices
    }
}
