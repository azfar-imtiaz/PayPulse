//
//  InvoiceListContainer.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-07-03.
//

import SwiftUI
import OrderedCollections

struct RentalInvoiceListContainer: View {
    @Binding var selectedYear : Int
    let vendor                : String
    let yearlyInvoices        : OrderedDictionary<Int, [RentalInvoice]>
    var refreshAction         : () async -> Void = {}
    @Namespace private var zoomNamespace

    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: Radius.pill)
                .fill(Color.primarySurface)
                .ignoresSafeArea(edges: .bottom)
            
            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: Radius.xs)
                    .fill(Color.secondaryText.opacity(0.3))
                    .frame(width: 36, height: 4)
                    .padding(.top, Spacing.sm) // rounded 10->8 to match .bottom below
                    .padding(.bottom, Spacing.sm)

                ScrollView(.vertical, showsIndicators: false) {
                    if let invoices = yearlyInvoices[selectedYear], !invoices.isEmpty {
                        ForEach(Array(invoices.enumerated()), id: \.element.id) { index, invoice in
                            InvoiceListRow(
                                monthLabel: invoice.getDueMonthName(),
                                monthColor: .accentDeepOrange,
                                alignment: .center,
                                vendor: vendor,
                                dueDate: invoice.dueDate,
                                totalAmount: invoice.totalAmount,
                                currency: "SEK",
                                trailingIndicator: .statusBadge,
                                transitionID: invoice.invoiceID,
                                namespace: zoomNamespace
                            ) {
                                RentalDetailsView(invoice: invoice)
                            }
                            .padding([.horizontal, .top])
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                            .animation(.easeOut.delay(Double(index) * 0.03), value: selectedYear)
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
    RentalInvoiceListContainer(
        selectedYear: .constant(2025),
        vendor: "Wallenstam",
        yearlyInvoices: OrderedDictionary(
            uniqueKeysWithValues: [
                2025: [
                    RentalInvoice(
                        invoiceID: "invoice_1",
                        filename: "filename",
                        hyra: 7800,
                        el: 123,
                        kallvatten: 234,
                        varmvatten: 435,
                        totalAmount: 12000,
                        dueDateMonth: "01",
                        dueDateYear: "2025",
                        dueDate: "30-01-2025",
                        moms: 123,
                        ocr: "123456789"
                    ),
                    RentalInvoice(
                        invoiceID: "invoice_2",
                        filename: "filename",
                        hyra: 7800,
                        el: 123,
                        kallvatten: 234,
                        varmvatten: 435,
                        totalAmount: 14000,
                        dueDateMonth: "02",
                        dueDateYear: "2025",
                        dueDate: "30-02-2025",
                        moms: 123,
                        ocr: "123456789"
                    )
                ],
                2024: [
                    RentalInvoice(
                        invoiceID: "invoice_ID",
                        filename: "filename",
                        hyra: 7800,
                        el: 123,
                        kallvatten: 234,
                        varmvatten: 435,
                        totalAmount: 12000,
                        dueDateMonth: "12",
                        dueDateYear: "2024",
                        dueDate: "30-12-2024",
                        moms: 123,
                        ocr: "123456789"
                    )
                ]
            ]
        )
    )
}
