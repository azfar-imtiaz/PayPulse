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
    @StateObject var viewModel: RetailInvoicesViewModel
    @State private var selectedYear: Int = Utils.getCurrentYear()
    @State private var showSpinner: Bool = false
    @State private var loadingText: String = ""

    @Environment(\.presentToast) var presentToast
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        ZStack(alignment: .center) {
            if viewModel.hasLoadedInvoices(for: subType) && viewModel.invoicesByYear(for: subType).count > 0 {
                InvoiceYearListShell(years: Array(viewModel.invoicesByYear(for: subType).keys), selectedYear: $selectedYear) {
                    RetailInvoiceListContainer(
                        selectedYear: $selectedYear,
                        subType: subType,
                        viewModel: viewModel,
                        refreshAction: { fetchLatestInvoices() }
                    )
                }
            } else if viewModel.hasLoadedInvoices(for: subType) {
                NoInvoicesFoundView(subtitle: "No invoices found in this category yet. Try reloading or check back later.", showSpinner: $showSpinner) {
                    loadInvoices()
                }
            }

            LoadingDotsView(isLoading: $showSpinner, loadingText: loadingText)
        }
        .navigationBarBackButtonHidden()
        .onAppear {
            loadingText = "Loading \(subType.displayName.lowercased()) invoices..."
            if !viewModel.hasLoadedInvoices(for: subType) {
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

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    fetchLatestInvoices()
                } label: {
                    Utils.getIconColored(colorScheme: colorScheme, iconName: "refresh-ccw-dot")
                }
                .disabled(showSpinner)
            }
        }
    }

    private func fetchLatestInvoices() {
        showSpinner = true
        loadingText = "Checking for new \(subType.displayName.lowercased()) invoices..."

        Task {
            defer { showSpinner = false }
            await checkForLatestInvoices()
        }
    }

    private func checkForLatestInvoices() async {
        do {
            _ = try await viewModel.fetchLatestInvoices(for: subType)
            let toastValue = ToastValue(
                icon: Icon(name: "circle-check"),
                message: viewModel.successMessage ?? "Done."
            )
            presentToast(toastValue)
        } catch let apiError as APIError {
            Utils.handleAPITokenExpiration(apiError, authManager: authManager) {
                let errorToast = ToastValue(
                    icon: Icon(name: "circle-x"),
                    message: "Failed to check for new invoices: \(viewModel.errorMessage ?? apiError.errorDescription ?? apiError.localizedDescription)"
                )
                presentToast(errorToast)
            }
        } catch {}
    }

    private func loadInvoices() {
        showSpinner = true
        viewModel.loadedSubTypes.remove(subType)

        Task {
            defer {
                showSpinner = false
                viewModel.loadedSubTypes.insert(subType)
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
            ),
            viewModel: RetailInvoicesViewModel(
                invoiceService: InvoiceService(
                    apiClient: PayPulseAPIClient(
                        authManager: AuthManager.shared
                    )
                )
            )
        )
    }
}
