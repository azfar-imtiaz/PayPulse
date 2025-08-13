//
//  RentalListViewV2.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-07-02.
//

import SwiftUI

struct RentalListView: View {
    @StateObject var viewModel    : InvoicesViewModel
    @Binding var selectedYear     : Int
    @Binding var showSpinner      : Bool
    var loadInvoicesAction        : () async throws -> Void
    
    var body: some View {
        if viewModel.invoicesHaveLoaded && viewModel.invoices.count > 0 {
            VStack {
                HeaderYears(
                    years: Array(viewModel.invoices.keys),
                    selectedYear: $selectedYear
                )
                .padding(.horizontal)
                .padding(.bottom, 20)
                
                InvoiceListContainer(
                    selectedYear: $selectedYear,
                    vendor: "Wallenstam",
                    yearlyInvoices: viewModel.invoices
                )
            }
            .background(Color.secondaryDarkGray)
        } else if viewModel.invoicesHaveLoaded {
            NoInvoicesFoundView(showSpinner: $showSpinner) {
                try await loadInvoicesAction()
            }
        }
    }
}

#Preview {
    RentalListView(
        viewModel: InvoicesViewModel(
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
