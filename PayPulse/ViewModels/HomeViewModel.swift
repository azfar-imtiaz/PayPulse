//
//  HomeViewModel.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2026-11-09.
//

import Foundation
import OSLog

class HomeViewModel: ObservableObject {
    @Published var summary: InvoiceSummaryResponse?
    @Published var summaryHasLoaded: Bool = false
    @Published var recentInvoices: [InvoiceSummaryItem] = []
    @Published var recentInvoicesHaveLoaded: Bool = false
    @Published var errorMessage: String?

    private let invoiceService: InvoiceService
    private static let logger = Logger(subsystem: "PayPulse", category: "HomeViewModel")

    init(invoiceService: InvoiceService) {
        self.invoiceService = invoiceService
    }

    @MainActor
    func loadSummary() async {
        do {
            self.summary = try await invoiceService.getInvoiceSummary()
        } catch {
            self.errorMessage = (error as? APIError)?.localizedDescription ?? error.localizedDescription
            Self.logger.error("(loadSummary): The following error occurred: \(error.localizedDescription)")
        }

        self.summaryHasLoaded = true
    }

    @MainActor
    func loadRecentInvoices(limit: Int = 5) async {
        do {
            self.recentInvoices = try await invoiceService.getRecentInvoices(limit: limit)?.invoices ?? []
        } catch {
            self.errorMessage = (error as? APIError)?.localizedDescription ?? error.localizedDescription
            Self.logger.error("(loadRecentInvoices): The following error occurred: \(error.localizedDescription)")
        }

        self.recentInvoicesHaveLoaded = true
    }
}
