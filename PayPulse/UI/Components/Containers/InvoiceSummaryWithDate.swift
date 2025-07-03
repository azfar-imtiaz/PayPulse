//
//  InvoiceSummaryWithDate.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-07-03.
//

import SwiftUI

struct InvoiceSummaryWithDate: View {
    let invoice : InvoiceModel
    let vendor  : String
    
    var body: some View {
        HStack(alignment: .lastTextBaseline, spacing: 15) {
            Text(invoice.getDueMonthName())
                .font(.custom("Montserrat-SemiBold", size: 24))
                .foregroundStyle(Color.accentDeepOrange)
                .frame(width: 70, alignment: .leading)
            
            NavigationLink {
                RentalDetailsView(invoice: invoice)
            } label: {
                InvoiceDetailsContainer {
                    InvoiceSummary(
                        vendor: vendor,
                        dueDate: invoice.dueDate,
                        totalAmount: invoice.totalAmount
                    )
                }
            }
        }
    }
}

#Preview {
    InvoiceSummaryWithDate(
        invoice: InvoiceModel(
            invoiceID: "invoice_ID",
            filename: "filename",
            hyra: 7800,
            el: 123,
            kallvatten: 234,
            varmvatten: 435,
            totalAmount: 12000,
            dueDateMonth: "02",
            dueDateYear: "2023",
            dueDate: "30-11-2023",
            moms: 123,
            ocr: "123456789"
        ),
        vendor: "Wallenstam"
    )
}
