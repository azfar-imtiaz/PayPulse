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
    @Published var previousSummary: InvoiceSummaryResponse?
    @Published var summaryHasLoaded: Bool = false
    @Published var recentInvoices: [InvoiceSummaryItem] = []
    @Published var recentInvoicesHaveLoaded: Bool = false
    @Published var errorMessage: String?

    /// The period the spending graph covers. Calendar month for now; custom periods come later.
    @Published private(set) var period: SpendingPeriod = .calendarMonth(containing: Date())

    private let invoiceService: InvoiceService
    private static let logger = Logger(subsystem: "PayPulse", category: "HomeViewModel")

    init(invoiceService: InvoiceService) {
        self.invoiceService = invoiceService
    }

    @MainActor
    func loadSummary() async {
        period = .calendarMonth(containing: Date())
        let previousPeriod = period.previous()

        // Current month uses the backend default; only the comparison month needs an explicit value
        async let currentRequest = invoiceService.getInvoiceSummary(includeItems: true)
        async let previousRequest = invoiceService.getInvoiceSummary(
            month: previousPeriod.monthParameter,
            includeItems: true
        )

        do {
            self.summary = try await currentRequest
        } catch {
            self.errorMessage = (error as? APIError)?.localizedDescription ?? error.localizedDescription
            Self.logger.error("(loadSummary): The following error occurred: \(error.localizedDescription)")
        }

        // The comparison line is optional — a failure here just hides it
        do {
            self.previousSummary = try await previousRequest
        } catch {
            self.previousSummary = nil
            Self.logger.error("(loadSummary): Failed to load previous month: \(error.localizedDescription)")
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

    // MARK: - Spending graph

    var hasRent: Bool { summary?.rental != nil }
    var hasPreviousMonth: Bool { previousSummary != nil }

    func total(includeRent: Bool) -> Double {
        guard let summary else { return 0 }
        let rent = includeRent ? (summary.rental?.totalAmount ?? 0) : 0
        return summary.retail.totalAmount + rent
    }

    func currentSeries(includeRent: Bool, now: Date = Date()) -> [SpendingPoint] {
        SpendingSeries.build(
            items: summary?.retail.items ?? [],
            rentAmount: includeRent ? summary?.rental?.totalAmount : nil,
            period: period,
            through: now
        )
    }

    /// Previous period's full curve, or empty if it failed to load.
    func previousSeries(includeRent: Bool) -> [SpendingPoint] {
        guard let previousSummary else { return [] }
        let previousPeriod = period.previous()
        return SpendingSeries.build(
            items: previousSummary.retail.items ?? [],
            rentAmount: includeRent ? previousSummary.rental?.totalAmount : nil,
            period: previousPeriod,
            through: previousPeriod.end
        )
    }
}
