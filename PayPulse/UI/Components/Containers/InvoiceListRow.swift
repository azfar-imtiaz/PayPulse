//
//  InvoiceListRow.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2026-11-01.
//

import SwiftUI

struct InvoiceListRow<Destination: View>: View {
    let monthLabel: String?
    let monthColor: Color
    let alignment: VerticalAlignment
    let vendor: String
    let dueDate: String
    let totalAmount: Int
    let currency: String
    let trailingIndicator: InvoiceTrailingIndicator
    @ViewBuilder let destination: () -> Destination

    var body: some View {
        HStack(alignment: alignment, spacing: 15) {
            if let monthLabel {
                Text(monthLabel)
                    .font(.headingMedium)
                    .foregroundStyle(monthColor)
                    .frame(width: 70, alignment: .leading)
            } else {
                Spacer()
                    .frame(width: 70)
            }

            NavigationLink {
                destination()
            } label: {
                InvoiceDetailsContainer {
                    InvoiceSummary(
                        vendor: vendor,
                        dueDate: dueDate,
                        totalAmount: totalAmount,
                        currency: currency,
                        trailingIndicator: trailingIndicator
                    )
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        InvoiceListRow(
            monthLabel: "Nov",
            monthColor: .accentDeepOrange,
            alignment: .center,
            vendor: "Wallenstam",
            dueDate: "12-11-2021",
            totalAmount: 5000,
            currency: "SEK",
            trailingIndicator: .statusBadge
        ) {
            Text("Destination")
        }
    }
}
