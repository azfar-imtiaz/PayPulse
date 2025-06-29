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
        VStack(alignment: .leading, spacing: 16) {
            displayDueDate(value: paymentDetails["dueDate"] as! String)
            
            Divider()
            
            displayOCR(value: paymentDetails["ocr"] as! String)
            
            Divider()
            
            displayTotalAmount(value: paymentDetails["totalAmount"] as! Int)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.secondaryDarkGray, lineWidth: 1)
        )
    }
    
    func displayDueDate(value: String) -> some View {
        HStack(spacing: 5) {
            Text("Due Date")
                .font(.custom("Gotham-Medium", size: 16))
                .foregroundStyle(Color.secondaryDarkGray)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // add code to properly format the date
            Text(value)
                .font(.custom("Gotham-Book", size: 16))
                .foregroundStyle(.gray)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
    
    func displayOCR(value: String) -> some View {
        HStack {
            Text("OCR Reference")
                .font(.custom("Gotham-Medium", size: 16))
                .foregroundStyle(Color.secondaryDarkGray)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 5) {
                Text(value)
                    .font(.custom("Gotham-Book", size: 16))
                    .foregroundStyle(.gray)
                
                Button {
                    copyTextToClipboard(text: value, isOCR: true)
                } label: {
                    Image("copy-icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
    
    func displayTotalAmount(value: Int) -> some View {
        HStack(spacing: 5) {
            Text("Total Amount")
                .font(.custom("Gotham-Medium", size: 16))
                .foregroundStyle(Color.secondaryDarkGray)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 5) {
                // Text(value, format: .currency(code: "SEK"))
                Text("\(Invoice.getAmountFormatted(amount: value)) kr")
                    .font(.custom("Gotham-Book", size: 16))
                    .foregroundStyle(.gray)
                
                Button {
                    copyTextToClipboard(text: String(value), isOCR: false)
                } label: {
                    Image("copy-icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
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
            "totalAmount": "10000"
        ],
        showOCRToast: .constant(false),
        showTotalAmountToast: .constant(false)
    )
}
