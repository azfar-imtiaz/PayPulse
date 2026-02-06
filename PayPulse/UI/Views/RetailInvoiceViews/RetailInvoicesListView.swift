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

    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentToast) var presentToast
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var authManager: AuthManager

    init(subType: RetailInvoiceSubType, invoiceService: InvoiceService) {
        self.subType = subType
        self.invoiceService = invoiceService
        _viewModel = StateObject(wrappedValue: RetailInvoicesViewModel(invoiceService: invoiceService))
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .center) {
                if viewModel.invoicesHaveLoadedForSubType && viewModel.retailInvoicesByYear.count > 0 {
                    VStack {
                        HeaderYears(
                            years: Array(viewModel.retailInvoicesByYear.keys),
                            selectedYear: $selectedYear
                        )
                        .padding(.horizontal)
                        .padding(.bottom, 20)

                        RetailInvoiceListContainer(
                            selectedYear: $selectedYear,
                            subType: subType,
                            viewModel: viewModel
                        )
                    }
                    .background(Color.secondaryDarkGray)
                } else if viewModel.invoicesHaveLoadedForSubType {
                    NoInvoicesFoundView(showSpinner: $showSpinner) {
                        try await loadInvoices()
                    }
                }

                LoadingDotsView(isLoading: $showSpinner, loadingText: loadingText)
            }
        }
        .navigationBarBackButtonHidden()
        .onAppear {
            loadingText = "Loading \(subType.displayName.lowercased()) invoices..."
            loadInvoices()
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    getIconColored(iconName: "circle-arrow-left")
                }
                .disabled(showSpinner)
            }

            ToolbarItem(placement: .principal) {
                Text(subType.displayName)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(computeToolbarTextColor())
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
            }
        }
    }

    private func computeToolbarTextColor() -> Color {
        if viewModel.retailInvoicesByYear.count > 0 {
            return Color.primaryOffWhite
        } else {
            return Color.secondaryDarkGray
        }
    }

    private func getIconColored(iconName: String) -> Image {
        if colorScheme == .dark {
            return viewModel.retailInvoicesByYear.count > 0 ? Image("\(iconName)-dark") : Image("\(iconName)-light")
        } else {
            return viewModel.retailInvoicesByYear.count > 0 ? Image("\(iconName)-light") : Image("\(iconName)-dark")
        }
    }
}

#Preview {
    RetailInvoicesListView(
        subType: .technology,
        invoiceService: InvoiceService(
            apiClient: PayPulseAPIClient(
                authManager: AuthManager.shared
            )
        )
    )
}