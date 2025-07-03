//
//  InvoiceView.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2024-11-21.
//

import SwiftUI
import Toasts

struct RentalDetailsView: View {
    let invoice: InvoiceModel
    @State private var showOCRToast: Bool = false
    @State private var showTotalAmountToast: Bool = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentToast) var presentToast
    
    var body: some View {
        VStack(alignment: .leading) {
            
            VStack(alignment: .leading, spacing: 0) {
                Text("Invoice ID")
                    .font(.custom("Gotham-Medium", size: 20))
                    .foregroundStyle(Color.secondaryDarkGray)
                
                Text(invoice.invoiceID)
                    .font(.custom("Gotham-Book", size: 16))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .foregroundStyle(.gray)
            }
            .padding([.horizontal, .top])
            
            Spacer()
            
            Text("Payment Details")
                .font(.custom("Gotham-Medium", size: 20))
                .foregroundStyle(Color.secondaryDarkGray)
            .padding(.horizontal)
            
            PaymentDetailsView(
                dueDate: invoice.dueDate,
                ocrRef: invoice.ocr,
                totalAmount: invoice.totalAmount,
                showOCRToast: $showOCRToast,
                showTotalAmountToast: $showTotalAmountToast
            )
            .padding(.horizontal)
            
            Spacer()
            
            Text("Rent Breakdown")
                .font(.custom("Gotham-Medium", size: 20))
                .foregroundStyle(Color.secondaryDarkGray)
                .padding(.horizontal)
            
            RentBreakdownView(
                baseRent: invoice.hyra,
                kallvatten: invoice.kallvatten,
                varmvatten: invoice.varmvatten,
                electricity: invoice.el,
                moms: invoice.moms,
                totalAmount: invoice.totalAmount
            )
            .padding(.horizontal)             
            
            Spacer()
            
        }
        .onChange(of: showOCRToast) { _, newValue in
            if newValue {
                showTextCopiedToast(text: "OCR")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    showOCRToast = false
                }
            }
        }
        .onChange(of: showTotalAmountToast) { _, newValue in
            if newValue {
                showTextCopiedToast(text: "Total amount")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    showTotalAmountToast = false
                }
            }
        }
        .background(Color.primaryOffWhite)
        .navigationTitle("Invoice Details")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left.circle")
                        .foregroundStyle(Color.primaryOffWhite)
                }
            }
        }
    }
    
    func showTextCopiedToast(text: String) {
        let toast = ToastValue(icon: Image("copy-icon"), message: "\(text) copied!")
        presentToast(toast)
    }
}

#Preview {
    RentalDetailsView(
        invoice: InvoiceModel(
            invoiceID: "ID",
            filename: "Hyresavi_akjdjaskdjsak",
            hyra: 9500,
            el: -1,
            kallvatten: -1,
            varmvatten: -1,
            totalAmount: 10000,
            dueDateMonth: "05",
            dueDateYear: "2025",
            dueDate: "30-05-2025",
            moms: 200,
            ocr: "1234567890"
        )
    )
}
