//
//  RetailInvoiceSummaryWithDate.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-02-05.
//

import SwiftUI

struct RetailInvoiceSummaryWithDate: View {
    let invoice: RetailInvoiceBase
    let showMonth: Bool
    let subType: RetailInvoiceSubType

    var body: some View {
        HStack(alignment: .lastTextBaseline, spacing: 15) {
            if showMonth {
                Text(invoice.getMonthName())
                    .font(.headingMedium)
                    .foregroundStyle(subType.color)
                    .frame(width: 70, alignment: .leading)
            } else {
                Spacer()
                    .frame(width: 70)
            }

            NavigationLink {
                RetailInvoiceDetailView(invoice: invoice, subType: subType)
            } label: {
                InvoiceDetailsContainer {
                    InvoiceSummary(
                        vendor: invoice.vendorName,
                        dueDate: invoice.getFormattedDate(),
                        totalAmount: Int(invoice.totalAmount),
                        currency: invoice.displayCurrency,
                        circleColor: subType.color
                    )
                }
            }
        }
    }
}

#Preview {
    RetailInvoiceSummaryWithDate(
        invoice: RetailInvoiceBase(
            invoiceID: "retail_invoice_123",
            invoiceDate: "2025-02-05",
            totalAmount: 99.99,
            currency: "SEK",
            vendorName: "Test Vendor"
        ),
        showMonth: true,
        subType: .technology
    )
}