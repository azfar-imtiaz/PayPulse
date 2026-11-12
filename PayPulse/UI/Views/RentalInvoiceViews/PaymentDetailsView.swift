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
    @Binding var showOCRToast: Bool

    var body: some View {
        InvoiceDetailsContainer {
            KeyValueRow(
                key: "Due Date",
                value: dueDate,
                keyOpacity: 1.0
            )

            Divider()

            KeyValueRow(
                key: "OCR Reference",
                value: ocrRef,
                showCopyButton: true,
                copyButtonAction: {
                    copyTextToClipboard(text: ocrRef)
                },
                keyOpacity: 1.0
            )
        }
    }

    func copyTextToClipboard(text: String) {
        UIPasteboard.general.string = text
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        showOCRToast = true
    }
}

#Preview {
    PaymentDetailsView(
        dueDate: "30-05-2025",
        ocrRef: "1231231231",
        showOCRToast: .constant(false)
    )
}
