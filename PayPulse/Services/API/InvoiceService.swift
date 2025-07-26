//
//  InvoiceService.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-06-29.
//

import Foundation
import OrderedCollections

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
    
    func ingestLatestInvoice(type: String) async throws -> Int {
        let response: APISuccessResponse<EmptyData> = try await apiClient.request(
            path: "invoices/\(type)/ingest/latest",
            method: .post,
            parameters: nil
        )
        
        return response.code
    }
    
    func getRentalInvoices(type: String) async throws -> OrderedDictionary<Int, [InvoiceModel]> {
        let response: APISuccessResponse<InvoiceResponseModel> = try await apiClient.request(
            path: "invoices/\(type)",
            method: .get
        )
        
        guard let responseData = response.data else {
            return [:]
        }
        
        // sort the invoices by years, in descending order
        let modifiedInvoices: OrderedDictionary<Int, [InvoiceModel]> = OrderedDictionary(
            uniqueKeysWithValues: responseData.invoices.sorted(by: { $0.key > $1.key })
        )
        
        return modifiedInvoices
    }
}
