//
//  RentalListViewV2.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-07-02.
//

import SwiftUI

struct RentalListView: View {
    @StateObject var viewModel    : RentalInvoicesViewModel
    @Binding var selectedYear     : Int
    @Binding var showSpinner      : Bool
    var refreshAction             : () async -> Void = {}
    var loadInvoicesAction        : () async throws -> Void

    var body: some View {
        if viewModel.invoicesHaveLoaded && viewModel.invoices.count > 0 {
            InvoiceYearListShell(years: Array(viewModel.invoices.keys), selectedYear: $selectedYear) {
                RentalInvoiceListContainer(
                    selectedYear: $selectedYear,
                    vendor: "Wallenstam",
                    yearlyInvoices: viewModel.invoices,
                    refreshAction: refreshAction
                )
            }
        } else if viewModel.invoicesHaveLoaded {
            NoInvoicesFoundView(subtitle: "Click the button below to fetch rental invoices from your inbox.", showSpinner: $showSpinner) {
                try await loadInvoicesAction()
            }
        }
    }
}

#Preview {
    RentalListView(
        viewModel: RentalInvoicesViewModel(
            invoiceService: InvoiceService(
                apiClient: PayPulseAPIClient(
                    authManager: AuthManager.shared
                )
            )
        ),
        selectedYear: .constant(2025),
        showSpinner: .constant(false),
        loadInvoicesAction: {}
    )
}
