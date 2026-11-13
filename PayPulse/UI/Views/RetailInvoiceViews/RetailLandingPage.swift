//
//  RetailLandingPage.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2026-02-05.
//

import SwiftUI
import Toasts

struct RetailLandingPage: View {
    let invoiceService: InvoiceService
    @ObservedObject var viewModel: RetailInvoicesViewModel
    /// Shared with Home: holds this and last month's summary (incl. per-item retail data)
    @ObservedObject var summaryViewModel: HomeViewModel
    @State var showSpinner: Bool = false
    @State var loadingText: String = ""

    @Environment(\.presentToast) var presentToast
    @EnvironmentObject var authManager: AuthManager

    init(invoiceService: InvoiceService, viewModel: RetailInvoicesViewModel, summaryViewModel: HomeViewModel) {
        self.invoiceService = invoiceService
        self.viewModel = viewModel
        self.summaryViewModel = summaryViewModel
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .center) {
                VStack(spacing: 0) {
                    ScreenHeader(title: "Your retail invoices,", subtitle: "categorized.")

                    if viewModel.countsHaveLoaded {
                        ScrollView {
                            VStack(spacing: 12) {
                                monthCard

                                allInvoicesHeader
                                    .padding(.top, Spacing.lg)

                                ForEach(getSortedSubTypes(), id: \.0) { subType, count in
                                    CategorySummaryRow(
                                        iconColor: subType.color,
                                        icon: {
                                            Image(systemName: subType.sfSymbolName)
                                                .font(.headingCompact)
                                                .foregroundStyle(subType.color)
                                        },
                                        title: subType.displayName,
                                        count: count,
                                        subtitle: monthSubtitle(for: subType),
                                        destination: RetailInvoicesListView(
                                            subType: subType,
                                            invoiceService: invoiceService,
                                            viewModel: viewModel
                                        )
                                    )
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, Spacing.xl)
                        }
                        .padding(.top, Spacing.sm) // rounded 10->8
                        .floatingTabBarScrollBehavior()
                    } else {
                        Spacer()
                    }
                }
                .background(Color.primarySurface)
                .onAppear {
                    loadingText = "Loading invoice counts..."
                    if !viewModel.countsHaveLoaded {
                        loadInvoiceCounts()
                    }
                }

                LoadingDotsView(isLoading: $showSpinner, loadingText: loadingText)
            }
        }
    }

    private var monthCard: some View {
        let segments = summaryViewModel.retailSpendBySubtype()
        return RetailMonthCard(
            isLoaded: summaryViewModel.summaryHasLoaded,
            monthName: monthName,
            total: summaryViewModel.summary?.retail.totalAmount ?? 0,
            previousAtSamePoint: summaryViewModel.previousRetailAtSamePoint(),
            segments: segments
        )
    }

    private var allInvoicesHeader: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("All invoices")
                .font(.headingSmall)
                .fontWeight(.semibold)
                .foregroundStyle(Color.secondaryText)
            Spacer()
            Text("\(viewModel.getTotalCount()) total")
                .font(.chipLabel)
                .foregroundStyle(Color.secondaryText.opacity(0.6))
                .monospacedDigit()
        }
        .padding(.horizontal, Spacing.xs)
    }

    private var monthName: String {
        summaryViewModel.period.start.formatted(.dateTime.month(.wide))
    }

    /// Quiet second line on each category row: this month's spend in that category
    private func monthSubtitle(for subType: RetailInvoiceSubType) -> String? {
        guard summaryViewModel.summaryHasLoaded, summaryViewModel.summary != nil else { return nil }
        let amount = summaryViewModel.retailSpendBySubtype().first(where: { $0.subType == subType })?.amount ?? 0
        return amount > 0
            ? "\(Utils.formatCurrency(amount, currency: "SEK")) this month"
            : "Nothing this month"
    }

    private func getSortedSubTypes() -> [(RetailInvoiceSubType, Int)] {
        // Get all sub-types with their counts, including 0 counts for missing sub-types
        let allSubTypes = RetailInvoiceSubType.allCases.map { subType in
            let count = viewModel.getCount(for: subType)
            return (subType, count)
        }

        // Sort by count (highest first), then by display name for ties
        return allSubTypes.sorted { first, second in
            if first.1 != second.1 {
                return first.1 > second.1  // Higher count first
            }
            return first.0.displayName < second.0.displayName  // Alphabetical for ties
        }
    }

    private func loadInvoiceCounts() {
        showSpinner = true
        viewModel.countsHaveLoaded = false

        Task {
            defer {
                showSpinner = false
                viewModel.countsHaveLoaded = true
            }

            do {
                try await viewModel.getInvoiceCounts()
            } catch let apiError as APIError {
                Utils.handleAPITokenExpiration(apiError, authManager: authManager) {
                    let errorToast = ToastValue(
                        icon: Icon(name: "circle-x"),
                        message: "Failed to load invoice counts: \(viewModel.errorMessage ?? apiError.errorDescription ?? apiError.localizedDescription)"
                    )
                    presentToast(errorToast)
                }
            }
        }
    }
}

#Preview {
    let invoiceService = InvoiceService(apiClient: PayPulseAPIClient(authManager: AuthManager.shared))
    RetailLandingPage(
        invoiceService: invoiceService,
        viewModel: RetailInvoicesViewModel(invoiceService: invoiceService),
        summaryViewModel: HomeViewModel(invoiceService: invoiceService)
    )
}
