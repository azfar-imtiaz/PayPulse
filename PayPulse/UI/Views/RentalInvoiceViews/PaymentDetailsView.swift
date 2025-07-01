//
//  PaymentDetailsView.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2024-12-30.
//

import SwiftUI

struct PaymentDetailsView: View {
    let paymentDetails: [String: Any]
    @Binding var showOCRToast: Bool
    @Binding var showTotalAmountToast: Bool
    
    var body: some View {
        InvoiceDetailsContainer {
            KeyValueRow(
                key: "Due Date",
                value: paymentDetails["dueDate"] as Any
            )
            
            Divider()
            
            KeyValueRow(
                key: "OCR Reference",
                value: paymentDetails["ocr"] as Any,
                showCopyButton: true,
                copyButtonAction: {
                    copyTextToClipboard(
                        text: paymentDetails["ocr"] as! String,
                        isOCR: true
                    )
                }
            )
            
            Divider()
            
            KeyValueRow(
                key: "Total Amount",
                value: paymentDetails["totalAmount"] as Any,
                showCopyButton: true,
                copyButtonAction: {
                    copyTextToClipboard(
                        text: paymentDetails["totalAmount"] as! String,
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
        paymentDetails: [
            "dueDate": "12/30/21",
            "ocr": "123456789",
            "totalAmount": 10000
        ],
        showOCRToast: .constant(false),
        showTotalAmountToast: .constant(false)
    )
}
