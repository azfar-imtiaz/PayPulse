//
//  RetailInvoiceListContainer.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-02-05.
//

import SwiftUI
import OrderedCollections

struct RetailInvoiceListContainer: View {
    @Binding var selectedYear: Int
    let subType: RetailInvoiceSubType
    let viewModel: RetailInvoicesViewModel

    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 40)
                .fill(Color.primaryOffWhite)
                .ignoresSafeArea(edges: .bottom)

            VStack {
                ScrollView(.vertical, showsIndicators: false) {
                    let invoicesWithMonthDisplay = viewModel.getInvoicesWithMonthDisplay(for: selectedYear)

                    if !invoicesWithMonthDisplay.isEmpty {
                        ForEach(Array(invoicesWithMonthDisplay.enumerated()), id: \.offset) { index, invoiceData in
                            let (invoice, showMonth) = invoiceData

                            RetailInvoiceSummaryWithDate(
                                invoice: invoice,
                                showMonth: showMonth,
                                subType: subType
                            )
                            .padding([.horizontal, .top])
                        }
                    } else {
                        VStack(spacing: 20) {
                            Spacer(minLength: 100)

                            Text("No invoices found for \(selectedYear.description)")
                                .font(.headingStandard)
                                .foregroundStyle(.gray)
                                .multilineTextAlignment(.center)

                            Text("Select a different year or check back later")
                                .font(.bodyStandard)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)

                            Spacer()
                        }
                        .padding()
                    }
                }
            }
            .padding(.top)
        }
    }
}

#Preview {
    RetailInvoiceListContainer(
        selectedYear: .constant(2025),
        subType: .technology,
        viewModel: RetailInvoicesViewModel(
            invoiceService: InvoiceService(
                apiClient: PayPulseAPIClient(
                    authManager: AuthManager.shared
                )
            )
        )
    )
}
