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
            KeyValueRow(
                key: "Category",
                value: subType.displayName
            )

            Divider()

            KeyValueRow(
                key: "Vendor",
                value: invoice.vendorName
            )

            Divider()

            KeyValueRow(
                key: "Invoice Date",
                value: invoice.getFormattedDate()
            )

            Divider()

            KeyValueRow(
                key: "Total Amount",
                value: invoice.getFormattedAmount(),
                showCopyButton: true,
                copyButtonAction: {
                    copyTextToClipboard(text: invoice.getFormattedAmount())
                }
            )
        }
    }

    private func copyTextToClipboard(text: String) {
        UIPasteboard.general.string = text
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
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