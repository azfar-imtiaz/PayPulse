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
        VStack(alignment: .leading, spacing: Spacing.lg) {
            ReceiptHeroTotal(
                amount: Double(totalAmount),
                currency: "SEK",
                showCopyButton: true,
                copyButtonAction: {
                    copyTextToClipboard(
                        text: "\(totalAmount)",
                        isOCR: false
                    )
                }
            )

            InvoiceDetailsContainer {
                KeyValueRow(
                    key: "Due Date",
                    value: dueDate,
                    keyOpacity: 0.6
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
                    },
                    keyOpacity: 0.6
                )
            }
        }
    }
    
    func copyTextToClipboard(text: String, isOCR: Bool) {
        UIPasteboard.general.string = text
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
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
