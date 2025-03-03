//
//  InvoiceView.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2024-11-21.
//

import SwiftUI
import Toasts

struct InvoiceView: View {
    let invoice: Invoice
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
                
                Text(invoice.id)
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
                paymentDetails: [
                    "dueDate": invoice.dueDate,
                    "ocr": invoice.ocr_reference,
                    "totalAmount": invoice.totalAmount
                ],
                showOCRToast: $showOCRToast,
                showTotalAmountToast: $showTotalAmountToast
            )
            .padding(.horizontal)
            
            Spacer()
            
            Text("Rent Breakdown")
                .font(.custom("Gotham-Medium", size: 20))
                .foregroundStyle(Color.secondaryDarkGray)
                .padding(.horizontal)
            
            RentBreakdownView(breakdown: [
                ("Base rent", invoice.hyra_amount),
                ("Kallvatten", invoice.kallvatten_amount),
                ("Varmvatten", invoice.varmvatten_amount),
                ("Electricity", invoice.electricity_amount),
                ("Moms", invoice.moms_amount),
                ("Total", invoice.totalAmount)
            ])
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
    InvoiceView(invoice: Invoice(id: "ID", dueDate: "2024-11-08", dueDateMonthYear: "November, 2024", ocr_reference: "1234567890", filename: "Hyresavi_akjdjaskdjsak", electricity_amount: -1, hyra_amount: "", kallvatten_amount: -1, varmvatten_amount: -1, mervärdesskatt_amount: -1, moms_amount: -1, totalAmount: "10,000"))
}
