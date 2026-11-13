//
//  RetailMonthInvoicesView.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2026-11-13.
//

import SwiftUI

/// Opened from the Retail month card: every retail invoice behind a month's total, newest first,
/// filterable by category. A ‹ month › switcher in the nav bar browses earlier months.
struct RetailMonthInvoicesView: View {
    let invoiceService: InvoiceService
    @ObservedObject var retailViewModel: RetailInvoicesViewModel
    /// The newest month the user can browse to (the current period)
    private let latestPeriod: SpendingPeriod

    @State private var period: SpendingPeriod
    /// Retail items per month (keyed by `SpendingPeriod.monthParameter`), seeded with what Home loaded
    @State private var cache: [String: [InvoiceSummaryItem]]
    @State private var isLoading = false
    @State private var loadFailed = false

    /// nil = all categories
    @State private var filter: RetailInvoiceSubType? = nil
    @Namespace private var zoomNamespace

    init(
        invoiceService: InvoiceService,
        retailViewModel: RetailInvoicesViewModel,
        period: SpendingPeriod,
        items: [InvoiceSummaryItem],
        previousItems: [InvoiceSummaryItem]?
    ) {
        self.invoiceService = invoiceService
        self.retailViewModel = retailViewModel
        self.latestPeriod = period
        _period = State(initialValue: period)
        var seed = [period.monthParameter: items]
        if let previousItems {
            seed[period.previous().monthParameter] = previousItems
        }
        _cache = State(initialValue: seed)
    }

    private var items: [InvoiceSummaryItem] { cache[period.monthParameter] ?? [] }
    private var isLatestMonth: Bool { period == latestPeriod }
    private var monthTitle: String { period.start.formatted(.dateTime.month(.wide).year()) }

    private static func subType(of item: InvoiceSummaryItem) -> RetailInvoiceSubType {
        item.subType.flatMap { RetailInvoiceSubType(rawValue: $0) } ?? .miscellaneous
    }

    /// Category totals for the whole month, largest first (drives the bar and the chips)
    private var segments: [(subType: RetailInvoiceSubType, amount: Double)] {
        var totals: [RetailInvoiceSubType: Double] = [:]
        for item in items {
            totals[Self.subType(of: item), default: 0] += item.totalAmount
        }
        return totals
            .filter { $0.value > 0 }
            .map { (subType: $0.key, amount: $0.value) }
            .sorted { $0.amount > $1.amount }
    }

    /// Newest first; invoice_date is yyyy-MM-dd so string order is date order
    private var visibleItems: [InvoiceSummaryItem] {
        items
            .filter { filter == nil || Self.subType(of: $0) == filter }
            .sorted { $0.invoiceDate > $1.invoiceDate }
    }

    private var visibleTotal: Double {
        visibleItems.reduce(0) { $0 + $1.totalAmount }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                summary
                rows
            }
            .padding(.horizontal)
            .padding(.vertical, Spacing.lg)
        }
        .background(Color.primarySurface)
        .floatingTabBarScrollBehavior()
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackButton()
            }
            ToolbarItem(placement: .principal) {
                monthSwitcher
            }
        }
        .sensoryFeedback(.selection, trigger: period)
    }

    // MARK: - Month switcher

    private var monthSwitcher: some View {
        HStack(spacing: Spacing.md) {
            Button {
                show(period.previous())
            } label: {
                Image(systemName: "chevron.left")
                    .frame(width: 32, height: 32)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("Previous month")

            Text(monthTitle)
                .font(.navigationStandard)
                .foregroundStyle(Color.secondaryText)
                .monospacedDigit()
                .contentTransition(.numericText())
                .frame(minWidth: 150)

            Button {
                show(period.next())
            } label: {
                Image(systemName: "chevron.right")
                    .frame(width: 32, height: 32)
                    .contentShape(Rectangle())
            }
            .disabled(isLatestMonth)
            .opacity(isLatestMonth ? 0.25 : 1)
            .accessibilityLabel("Next month")
        }
        .font(.system(size: 15, weight: .semibold))
        .foregroundStyle(Color.secondaryText)
    }

    private func show(_ newPeriod: SpendingPeriod) {
        withAnimation(.snappy) {
            period = newPeriod
            loadFailed = false
        }
        // Keep a category filter only if that category exists in the new month
        if let filter, !segments.contains(where: { $0.subType == filter }), cache[newPeriod.monthParameter] != nil {
            self.filter = nil
        }
        guard cache[newPeriod.monthParameter] == nil else { return }
        load(newPeriod)
    }

    private func load(_ target: SpendingPeriod) {
        isLoading = true
        loadFailed = false
        Task {
            do {
                let summary = try await invoiceService.getInvoiceSummary(month: target.monthParameter, includeItems: true)
                cache[target.monthParameter] = summary?.retail.items ?? []
            } catch {
                if target == period { loadFailed = true }
            }
            // Ignore completions for months the user already moved away from
            if target == period {
                withAnimation(.snappy) {
                    isLoading = false
                    if let filter, !segments.contains(where: { $0.subType == filter }) {
                        self.filter = nil
                    }
                }
            }
        }
    }

    // MARK: - Summary

    private var summary: some View {
        SoftCard(padding: Spacing.xl) {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                HStack(alignment: .firstTextBaseline, spacing: Spacing.sm) {
                    Text(Utils.formatCurrency(visibleTotal.rounded(), currency: "SEK"))
                        .font(.headingMedium)
                        .foregroundStyle(filter?.color ?? Color.accentDeepRed)
                        .monospacedDigit()
                        .contentTransition(.numericText(value: visibleTotal))

                    Text(countLabel)
                        .font(.bodyStandard)
                        .foregroundStyle(Color.secondaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }

                if !segments.isEmpty {
                    CategoryBarChart(segments: segments, selection: $filter)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var countLabel: String {
        let count = visibleItems.count
        let noun = count == 1 ? "invoice" : "invoices"
        if let filter {
            return "· \(count) \(noun) in \(filter.displayName)"
        }
        return "· \(count) \(noun)"
    }

    // MARK: - Rows

    @ViewBuilder
    private var rows: some View {
        if isLoading && cache[period.monthParameter] == nil {
            ProgressView()
                .frame(maxWidth: .infinity)
                .padding(.top, Spacing.xxl)
        } else if loadFailed {
            VStack(spacing: Spacing.sm) {
                Text("Couldn't load \(monthTitle).")
                    .font(.bodyStandard)
                    .foregroundStyle(Color.secondaryText)
                Button("Try again") { load(period) }
                    .font(.buttonCompact)
                    .foregroundStyle(Color.accentDeepRed)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, Spacing.xxl)
        } else if visibleItems.isEmpty {
            Text(isLatestMonth ? "No retail invoices yet this month." : "No retail invoices in \(monthTitle).")
                .font(.bodyStandard)
                .foregroundStyle(Color.secondaryText.opacity(0.7))
                .frame(maxWidth: .infinity)
                .padding(.top, Spacing.xxl)
        } else {
            VStack(spacing: Spacing.md) {
                ForEach(visibleItems) { item in
                    InvoiceListRow(
                        monthLabel: nil,
                        monthColor: .accentDeepRed,
                        alignment: .center,
                        showMonthGutter: false,
                        vendor: item.vendorName ?? "Unknown vendor",
                        dueDate: item.getFormattedDueDate(),
                        totalAmount: Int(item.totalAmount.rounded()),
                        currency: item.currency ?? "SEK",
                        trailingIndicator: .dot(Self.subType(of: item).color),
                        transitionID: "retail_month_\(item.invoiceID)",
                        namespace: zoomNamespace
                    ) {
                        RetailInvoiceDetailView(
                            invoice: RetailInvoiceBase(
                                invoiceID: item.invoiceID,
                                invoiceDate: item.invoiceDate,
                                totalAmount: item.totalAmount,
                                currency: item.currency,
                                vendorName: item.vendorName ?? ""
                            ),
                            subType: Self.subType(of: item),
                            retailViewModel: retailViewModel
                        )
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .animation(.snappy, value: filter)
        }
    }
}
