//
//  RetailInvoicesListView.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-02-05.
//

import SwiftUI
import Toasts

struct RetailInvoicesListView: View {
    let subType: RetailInvoiceSubType
    let invoiceService: InvoiceService
    @StateObject private var viewModel: RetailInvoicesViewModel
    @State private var selectedYear: Int = Utils.getCurrentYear()
    @State private var showSpinner: Bool = false
    @State private var loadingText: String = ""

    @Environment(\.presentToast) var presentToast
    @EnvironmentObject var authManager: AuthManager

    init(subType: RetailInvoiceSubType, invoiceService: InvoiceService) {
        self.subType = subType
        self.invoiceService = invoiceService
        _viewModel = StateObject(wrappedValue: RetailInvoicesViewModel(invoiceService: invoiceService))
    }

    var body: some View {
        ZStack(alignment: .center) {
            if viewModel.invoicesHaveLoadedForSubType && viewModel.retailInvoicesByYear.count > 0 {
                VStack {
                    HeaderYears(
                        years: Array(viewModel.retailInvoicesByYear.keys),
                        selectedYear: $selectedYear
                    )
                    .padding(.horizontal)
                    .padding(.bottom, Spacing.xl)

                    RetailInvoiceListContainer(
                        selectedYear: $selectedYear,
                        subType: subType,
                        viewModel: viewModel,
                        refreshAction: refreshInvoices
                    )
                }
                .background(Color.secondaryDarkGray)
            } else if viewModel.invoicesHaveLoadedForSubType {
                NoInvoicesFoundView(showSpinner: $showSpinner, subtitle: "No invoices found in this category yet. Try reloading or check back later.") {
                    loadInvoices()
                }
            }

            LoadingDotsView(isLoading: $showSpinner, loadingText: loadingText)
        }
        .navigationBarBackButtonHidden()
        .onAppear {
            loadingText = "Loading \(subType.displayName.lowercased()) invoices..."
            if !viewModel.invoicesHaveLoadedForSubType {
                loadInvoices()
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackButton()
                    .disabled(showSpinner)
            }

            ToolbarItem(placement: .principal) {
                NavTitle(text: subType.displayName)
            }
        }
    }

    private func loadInvoices() {
        showSpinner = true
        viewModel.invoicesHaveLoadedForSubType = false

        Task {
            defer {
                showSpinner = false
                viewModel.invoicesHaveLoadedForSubType = true
            }

            await refreshInvoices()
        }
    }

    private func refreshInvoices() async {
        do {
            try await viewModel.getRetailInvoices(for: subType)
        } catch let apiError as APIError {
            Utils.handleAPITokenExpiration(apiError, authManager: authManager) {
                let errorToast = ToastValue(
                    icon: Icon(name: "circle-x"),
                    message: "Failed to load \(subType.displayName.lowercased()) invoices: \(viewModel.errorMessage ?? apiError.errorDescription ?? apiError.localizedDescription)"
                )
                presentToast(errorToast)
            }
        } catch {}
    }

}

#Preview {
    NavigationStack {
        RetailInvoicesListView(
            subType: .technology,
            invoiceService: InvoiceService(
                apiClient: PayPulseAPIClient(
                    authManager: AuthManager.shared
                )
            )
        )
    }
}
