//
//  InvoiceSummary.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-07-03.
//

import SwiftUI

enum InvoiceTrailingIndicator {
    case none
    case dot(Color)
}

struct InvoiceSummary: View {
    let vendor: String
    let dueDate: String
    let totalAmount: Int
    let currency: String
    let trailingIndicator: InvoiceTrailingIndicator

    init(vendor: String, dueDate: String, totalAmount: Int, currency: String = "SEK", trailingIndicator: InvoiceTrailingIndicator = .none) {
        self.vendor = vendor
        self.dueDate = dueDate
        self.totalAmount = totalAmount
        self.currency = currency
        self.trailingIndicator = trailingIndicator
    }

    var body: some View {
        VStack {
            HStack(alignment: .top) {
                Text(vendor)
                    .font(.buttonStandard)
                    .foregroundStyle(Color.secondaryText)
                    .multilineTextAlignment(.leading)
                Spacer()

                switch trailingIndicator {
                case .none:
                    EmptyView()
                case .dot(let color):
                    Circle()
                        .fill(color)
                        .frame(width: 8, height: 8)
                }
            }

            HStack {
                Text(Utils.formatCurrency(Double(totalAmount), currency: currency))
                Spacer()
                Text(dueDate)
            }
            .font(.bodyStandard)
            .foregroundStyle(Color.secondaryText)
        }
    }
}

#Preview {
    InvoiceSummary(
        vendor: "Wallenstam",
        dueDate: "12-11-2021",
        totalAmount: 5000
    )
}
