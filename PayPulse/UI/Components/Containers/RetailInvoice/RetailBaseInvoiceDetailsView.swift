//
//  RetailBaseInvoiceDetailsView.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-02-08.
//

import SwiftUI

struct RetailBaseInvoiceDetailsView: View {
    let invoice: RetailInvoiceBase
    let subType: RetailInvoiceSubType

    var body: some View {
        InvoiceDetailsContainer {
            KeyValueRow(
                key: "Category",
                value: subType.displayName,
                keyOpacity: 1.0
            )

            Divider()

            KeyValueRow(
                key: "Vendor",
                value: invoice.vendorName,
                keyOpacity: 1.0
            )

            Divider()

            KeyValueRow(
                key: "Invoice Date",
                value: invoice.getFormattedDate(),
                keyOpacity: 1.0
            )
        }
    }
}

#Preview {
    RetailBaseInvoiceDetailsView(
        invoice: RetailInvoiceBase(
            invoiceID: "retail_invoice_123",
            invoiceDate: "2025-02-05",
            totalAmount: 99.99,
            currency: "SEK",
            vendorName: "Test Vendor"
        ),
        subType: .technology
    )
}
