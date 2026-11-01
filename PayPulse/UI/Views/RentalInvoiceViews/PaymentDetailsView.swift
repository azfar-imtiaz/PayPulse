//
//  PaymentDetailsView.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2024-12-30.
//

import SwiftUI

struct PaymentDetailsView: View {
    let dueDate     : String
    let ocrRef      : String
    let totalAmount : Int
    @Binding var showOCRToast: Bool
    @Binding var showTotalAmountToast: Bool
    
    var body: some View {
        InvoiceDetailsContainer {
            KeyValueRow(
                key: "Due Date",
                value: dueDate
            )

            Divider()

            KeyValueRow(
                key: "OCR Reference",
                value: ocrRef,
                showCopyButton: true,
                copyButtonAction: {
                    copyTextToClipboard(
                        text: ocrRef,
                        isOCR: true
                    )
                }
            )

            Divider()

            KeyValueRow(
                key: "Total Amount",
                value: Utils.formatCurrency(Double(totalAmount), currency: "SEK"),
                showCopyButton: true,
                copyButtonAction: {
                    copyTextToClipboard(
                        text: "\(totalAmount)",
                        isOCR: false
                    )
                }
            )
        }
    }
    
    func copyTextToClipboard(text: String, isOCR: Bool) {
        UIPasteboard.general.string = text
        // The isOCR parameter is used to identify whether the OCR has been copied, or the totalAmount
        if isOCR {
            showOCRToast = true
        } else {
            showTotalAmountToast = true
        }
    }
}

#Preview {
    PaymentDetailsView(
        dueDate: "30-05-2025",
        ocrRef: "1231231231",
        totalAmount: 15000,
        showOCRToast: .constant(false),
        showTotalAmountToast: .constant(false)
    )
}
