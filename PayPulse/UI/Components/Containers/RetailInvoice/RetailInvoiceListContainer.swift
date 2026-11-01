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
    var refreshAction: () async -> Void = {}
    @Namespace private var zoomNamespace

    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: Radius.pill)
                .fill(Color.primaryOffWhite)
                .ignoresSafeArea(edges: .bottom)

            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: Radius.xs)
                    .fill(Color.secondaryDarkGray.opacity(0.3))
                    .frame(width: 36, height: 4)
                    .padding(.top, Spacing.sm) // rounded 10->8 to match .bottom below
                    .padding(.bottom, Spacing.sm)

                ScrollView(.vertical, showsIndicators: false) {
                    let invoicesWithMonthDisplay = viewModel.getInvoicesWithMonthDisplay(for: selectedYear)

                    if !invoicesWithMonthDisplay.isEmpty {
                        ForEach(Array(invoicesWithMonthDisplay.enumerated()), id: \.offset) { index, invoiceData in
                            let (invoice, showMonth) = invoiceData

                            InvoiceListRow(
                                monthLabel: showMonth ? invoice.getMonthName() : nil,
                                monthColor: subType.color,
                                alignment: .firstTextBaseline,
                                vendor: invoice.vendorName,
                                dueDate: invoice.getFormattedDate(),
                                totalAmount: Int(invoice.totalAmount),
                                currency: invoice.displayCurrency,
                                trailingIndicator: .dot(subType.color),
                                transitionID: invoice.invoiceID,
                                namespace: zoomNamespace
                            ) {
                                RetailInvoiceDetailView(invoice: invoice, subType: subType, retailViewModel: viewModel)
                            }
                            .padding([.horizontal, .top])
                        }
                    } else {
                        NoInvoicesForYearView(year: selectedYear)
                    }
                }
                .id(selectedYear)
                .transition(.opacity)
                .refreshable {
                    await refreshAction()
                }
            }
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
