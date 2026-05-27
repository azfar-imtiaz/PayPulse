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
    @StateObject var viewModel: RetailInvoicesViewModel
    @State var showSpinner: Bool = false
    @State var loadingText: String = ""

    @Environment(\.presentToast) var presentToast
    @EnvironmentObject var authManager: AuthManager

    init(invoiceService: InvoiceService) {
        self.invoiceService = invoiceService
        _viewModel = StateObject(wrappedValue: RetailInvoicesViewModel(invoiceService: invoiceService))
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .center) {
                VStack(spacing: 0) {
                    HStack {
                        Text("Your retail invoices,\ncategorized.")
                        // .font(.headingMedium)
                            .font(.headingStandard)
                            .foregroundStyle(.gray)

                        Spacer()
                    }
                    .padding([.leading, .bottom])

                    if viewModel.countsHaveLoaded {
                        ScrollView {
                            VStack(spacing: 12) {
                                summaryCard
                                ForEach(getSortedSubTypes(), id: \.0) { subType, count in
                                    RetailCategoryRow(
                                        subType: subType,
                                        invoiceCount: count,
                                        destination: RetailInvoicesListView(
                                            subType: subType,
                                            invoiceService: invoiceService
                                        )
                                    )
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 20)
                        }
                        .padding(.top, 10)
                    } else {
                        Spacer()
                    }
                }
                .background(Color.primaryOffWhite)
                .onAppear {
                    loadingText = "Loading invoice counts..."
                    loadInvoiceCounts()
                }

                LoadingDotsView(isLoading: $showSpinner, loadingText: loadingText)
            }
        }
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(viewModel.getTotalCount())")
                .font(.headingMedium)
                .foregroundStyle(Color.accentDeepOrange)
            Text("invoices across \(RetailInvoiceSubType.allCases.count) categories")
                .font(.bodyStandard)
                .foregroundStyle(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.primaryOffWhite)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.secondaryDarkGray.opacity(0.15), lineWidth: 1)
                )
        )
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
    RetailLandingPage(invoiceService: InvoiceService(apiClient: PayPulseAPIClient(authManager: AuthManager.shared)))
}
