//
//  RetailInvoicesViewModel.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-02-05.
//

import Foundation

@MainActor
class RetailInvoicesViewModel: ObservableObject {
    @Published var invoiceCounts: [RetailInvoiceSubType: Int] = [:]
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var countsHaveLoaded: Bool = false

    private let invoiceService: InvoiceService

    init(invoiceService: InvoiceService) {
        self.invoiceService = invoiceService
    }

    func getInvoiceCounts() async throws {
        errorMessage = nil

        do {
            let counts = try await invoiceService.getRetailInvoiceCounts()
            await MainActor.run {
                self.invoiceCounts = counts
                self.countsHaveLoaded = true
            }
        } catch {
            self.errorMessage = (error as? APIError)?.localizedDescription ?? error.localizedDescription
            print("Failed to get retail invoice counts: \(self.errorMessage ?? "Unknown error")")
            throw error
        }
    }

    /// Returns the total count across all retail invoice sub-types
    func getTotalCount() -> Int {
        return invoiceCounts.values.reduce(0, +)
    }

    /// Returns count for a specific sub-type, defaulting to 0 if not found
    func getCount(for subType: RetailInvoiceSubType) -> Int {
        return invoiceCounts[subType] ?? 0
    }

    /// Returns sub-types sorted by count in descending order
    func getSubTypesSortedByCount() -> [(RetailInvoiceSubType, Int)] {
        return invoiceCounts.sorted { $0.value > $1.value }
    }
}