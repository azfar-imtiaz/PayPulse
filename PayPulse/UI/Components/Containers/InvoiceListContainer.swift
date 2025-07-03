//
//  InvoiceListContainer.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-07-03.
//

import SwiftUI
import OrderedCollections

struct InvoiceListContainer: View {
    @Binding var selectedYear : Int
    let vendor                : String
    let yearlyInvoices        : OrderedDictionary<Int, [InvoiceModel]>
    
    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 40)
                .fill(Color.primaryOffWhite)
                .ignoresSafeArea(edges: .bottom)
            
            VStack {
                ScrollView(.vertical, showsIndicators: false) {
                    if let invoices = yearlyInvoices[selectedYear] {
                        ForEach(invoices) { invoice in
                            InvoiceSummaryWithDate(
                                invoice: invoice,
                                vendor: vendor
                            )
                            .padding([.horizontal, .top])
                        }
                    }
                }
            }
            .padding(.top)
        }
    }
}

#Preview {
    InvoiceListContainer(
        selectedYear: .constant(2025),
        vendor: "Wallenstam",
        yearlyInvoices: OrderedDictionary(
            uniqueKeysWithValues: [
                2025: [
                    InvoiceModel(
                        invoiceID: "invoice_1",
                        filename: "filename",
                        hyra: 7800,
                        el: 123,
                        kallvatten: 234,
                        varmvatten: 435,
                        totalAmount: 12000,
                        dueDateMonth: "01",
                        dueDateYear: "2025",
                        dueDate: "30-01-2025",
                        moms: 123,
                        ocr: "123456789"
                    ),
                    InvoiceModel(
                        invoiceID: "invoice_2",
                        filename: "filename",
                        hyra: 7800,
                        el: 123,
                        kallvatten: 234,
                        varmvatten: 435,
                        totalAmount: 14000,
                        dueDateMonth: "02",
                        dueDateYear: "2025",
                        dueDate: "30-02-2025",
                        moms: 123,
                        ocr: "123456789"
                    )
                ],
                2024: [
                    InvoiceModel(
                        invoiceID: "invoice_ID",
                        filename: "filename",
                        hyra: 7800,
                        el: 123,
                        kallvatten: 234,
                        varmvatten: 435,
                        totalAmount: 12000,
                        dueDateMonth: "12",
                        dueDateYear: "2024",
                        dueDate: "30-12-2024",
                        moms: 123,
                        ocr: "123456789"
                    )
                ]
            ]
        )
    )
}
