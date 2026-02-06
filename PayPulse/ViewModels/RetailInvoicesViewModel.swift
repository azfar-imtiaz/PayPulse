//
//  RetailInvoicesViewModel.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-02-05.
//

import Foundation
import OrderedCollections

@MainActor
class RetailInvoicesViewModel: ObservableObject {
    @Published var invoiceCounts: [RetailInvoiceSubType: Int] = [:]
    @Published var retailInvoicesByYear: OrderedDictionary<Int, [RetailInvoiceBase]> = [:]
    @Published var currentSubType: RetailInvoiceSubType?
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var countsHaveLoaded: Bool = false
    @Published var invoicesHaveLoadedForSubType: Bool = false

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

    /// Fetches retail invoices for a specific sub-type
    func getRetailInvoices(for subType: RetailInvoiceSubType) async throws {
        errorMessage = nil
        currentSubType = subType

        do {
            let invoices = try await invoiceService.getRetailInvoices(subType: subType)
            await MainActor.run {
                self.retailInvoicesByYear = invoices
                self.invoicesHaveLoadedForSubType = true
            }
        } catch {
            self.errorMessage = (error as? APIError)?.localizedDescription ?? error.localizedDescription
            print("Failed to get retail invoices for \(subType.displayName): \(self.errorMessage ?? "Unknown error")")
            throw error
        }
    }

    /// Returns invoices with month display logic for a specific year
    func getInvoicesWithMonthDisplay(for year: Int) -> [(RetailInvoiceBase, Bool)] {
        guard let invoices = retailInvoicesByYear[year] else {
            return []
        }

        return processInvoicesForMonthDisplay(invoices: invoices)
    }

    /// Determines which invoices should show month names (last invoice in each month)
    private func processInvoicesForMonthDisplay(invoices: [RetailInvoiceBase]) -> [(RetailInvoiceBase, Bool)] {
        var result: [(RetailInvoiceBase, Bool)] = []
        var lastInvoiceByMonth: [Int: Int] = [:]  // month -> index of last invoice

        // Group invoices by month and find the last invoice index for each month
        for (index, invoice) in invoices.enumerated() {
            let month = invoice.getMonthNumber()
            lastInvoiceByMonth[month] = index
        }

        // Mark invoices that should show month names
        for (index, invoice) in invoices.enumerated() {
            let month = invoice.getMonthNumber()
            let isLastInMonth = lastInvoiceByMonth[month] == index
            result.append((invoice, isLastInMonth))
        }

        return result
    }
}