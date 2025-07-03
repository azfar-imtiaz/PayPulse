//
//  RentalListViewV2.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-07-02.
//

import SwiftUI

struct RentalListView: View {
    @ObservedObject var viewModel : InvoicesViewModel
    @Binding var selectedYear     : Int
    
    var body: some View {
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
        selectedYear: .constant(2025)
    )
}
