//
//  InvoiceService.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-06-29.
//

import Foundation
import OrderedCollections
import Alamofire

class InvoiceService {
    private let apiClient: PayPulseAPIClient
    
    init(apiClient: PayPulseAPIClient) {
        self.apiClient = apiClient
    }
    
    // MARK: - Generic Ingestion Methods
    
    func ingestInvoices(type: InvoiceType, parameters: Parameters? = nil) async throws -> InvoiceCountModel {
        let response: APISuccessResponse<InvoiceCountModel> = try await apiClient.request(
            path: "invoices/\(type.apiPath)/ingest",
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default
        )
        
        guard let invoiceCount = response.data else {
            return InvoiceCountModel(invoiceCount: 0)
        }
        
        return invoiceCount
    }
    
    func ingestLatestInvoice(type: InvoiceType) async throws -> Int {
        let response: APISuccessResponse<EmptyData> = try await apiClient.request(
            path: "invoices/\(type.apiPath)/ingest/latest",
            method: .post,
            parameters: nil
        )
        
        return response.code
    }
    
    // MARK: - Rental Invoice Methods
    
    func getRentalInvoices() async throws -> OrderedDictionary<Int, [RentalInvoice]> {
        let response: APISuccessResponse<RentalInvoiceResponse> = try await apiClient.request(
            path: "invoices/\(InvoiceType.rental.apiPath)",
            method: .get
        )
        
        guard let responseData = response.data else {
            return [:]
        }
        
        // Sort the invoices by years, in descending order
        let modifiedInvoices: OrderedDictionary<Int, [RentalInvoice]> = OrderedDictionary(
            uniqueKeysWithValues: responseData.invoices.sorted(by: { $0.key > $1.key })
        )
        
        return modifiedInvoices
    }
    
    // MARK: - Retail Invoice Methods
    
    /// Fetches retail invoices for a specific sub-type grouped by year
    func getRetailInvoices(subType: RetailInvoiceSubType) async throws -> OrderedDictionary<Int, [RetailInvoiceBase]> {
        let response: APISuccessResponse<RetailInvoiceByYearResponse> = try await apiClient.request(
            path: "invoices/\(InvoiceType.retail.apiPath)",
            method: .get,
            parameters: ["subtype": subType.apiPath],
            encoding: URLEncoding.queryString
        )

        guard let responseData = response.data else {
            return [:]
        }

        return responseData.getInvoicesByYear()
    }

    /// Fetches retail invoice counts for all sub-types
    func getRetailInvoiceCounts() async throws -> [RetailInvoiceSubType: Int] {
        let response: APISuccessResponse<RetailInvoiceCountsResponse> = try await apiClient.request(
            path: "invoices/\(InvoiceType.retail.apiPath)",
            method: .get,
            parameters: ["counts": "true"],
            encoding: URLEncoding.queryString
        )

        guard let responseData = response.data else {
            return [:]
        }

        return responseData.getCountsBySubType()
    }

    // MARK: - Retail Invoice Detail Methods
    
    /// Fetches and decodes food delivery invoice details
    func getFoodDeliveryDetail(invoiceID: String) async throws -> FoodDeliveryDetail {
        // Create a custom response structure for this specific detail type
        struct FoodDeliveryDetailWrapper: Codable {
            let invoiceDetails: FoodDeliveryDetail
        }
        
        let response: APISuccessResponse<FoodDeliveryDetailWrapper> = try await apiClient.request(
            path: "invoices/\(InvoiceType.retail.apiPath)",
            method: .get,
            parameters: [
                "subtype": RetailInvoiceSubType.foodDelivery.apiPath,
                "invoice-id": invoiceID
            ],
            encoding: URLEncoding.queryString
        )
        
        guard let responseData = response.data else {
            throw APIError.decodingError(NSError(
                domain: "InvoiceService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "No food delivery detail data returned"]
            ))
        }
        
        return responseData.invoiceDetails
    }
    
    // TODO: Add methods for other retail sub-type details as they are implemented
    // func getClothingDetail(invoiceID: String) async throws -> ClothingDetail { ... }
    // func getTechnologyDetail(invoiceID: String) async throws -> TechnologyDetail { ... }
    // etc.
}
