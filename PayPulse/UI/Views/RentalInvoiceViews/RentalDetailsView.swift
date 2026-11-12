//
//  InvoiceView.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2024-11-21.
//

import SwiftUI
import Toasts

struct RentalDetailsView: View {
    let invoice: RentalInvoice
    @State private var showOCRToast: Bool = false
    @State private var showTotalAmountToast: Bool = false
    
    @Environment(\.presentToast) var presentToast

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                VStack(alignment: .leading, spacing: 0) {
                    Text("Invoice ID")
                        .font(.bodyLarge)
                        .bold()
                        .foregroundStyle(Color.secondaryDarkGray)

                    Text(invoice.invoiceID)
                        .font(.bodyStandard)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .foregroundStyle(Color.secondaryDarkGray)
                        .opacity(0.6)
                }
                .padding(.horizontal)

                ReceiptHeroTotal(
                    amount: Double(invoice.totalAmount),
                    currency: "SEK",
                    showCopyButton: true,
                    copyButtonAction: {
                        copyTextToClipboard(text: "\(invoice.totalAmount)")
                    }
                )
                .padding(.horizontal)

                Text("Invoice details")
                    .font(.bodyLarge)
                    .bold()
                    .foregroundStyle(Color.secondaryDarkGray)
                    .padding(.horizontal)

                PaymentDetailsView(
                    dueDate: invoice.dueDate,
                    ocrRef: invoice.ocr,
                    showOCRToast: $showOCRToast
                )
                .padding(.horizontal)

                Text("Rent Breakdown")
                    .font(.bodyLarge)
                    .bold()
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

                Spacer(minLength: 100)
            }
            .padding(.top)
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
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackButton()
            }

            ToolbarItem(placement: .principal) {
                NavTitle(text: "Invoice Details")
            }
        }
    }

    func showTextCopiedToast(text: String) {
        let toast = ToastValue(icon: Image("copy"), message: "\(text) copied!")
        presentToast(toast)
    }

    func copyTextToClipboard(text: String) {
        UIPasteboard.general.string = text
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        showTotalAmountToast = true
    }
}

#Preview {
    RentalDetailsView(
        invoice: RentalInvoice(
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
