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
    @Binding var showToast: Bool
    @Binding var toastMessage: String

    var body: some View {
        InvoiceDetailsContainer {
            KeyStringValueRow(
                key: "Category",
                value: subType.displayName
            )

            Divider()

            KeyStringValueRow(
                key: "Vendor",
                value: invoice.vendorName
            )

            Divider()

            KeyStringValueRow(
                key: "Invoice Date",
                value: invoice.getFormattedDate()
            )

            Divider()

            KeyStringValueRow(
                key: "Total Amount",
                value: invoice.getFormattedAmount(),
                showCopyButton: true,
                copyButtonAction: {
                    copyTextToClipboard(text: invoice.getFormattedAmount())
                }
            )

            Divider()

            KeyStringValueRow(
                key: "Currency",
                value: invoice.displayCurrency
            )
        }
    }

    private func copyTextToClipboard(text: String) {
        UIPasteboard.general.string = text
        toastMessage = "Total amount copied!"
        showToast = true
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
        subType: .technology,
        showToast: .constant(false),
        toastMessage: .constant("")
    )
}