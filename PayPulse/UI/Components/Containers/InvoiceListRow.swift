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
    var showMonthGutter: Bool = true
    let vendor: String
    let dueDate: String
    let totalAmount: Int
    let currency: String
    let trailingIndicator: InvoiceTrailingIndicator
    let transitionID: String
    let namespace: Namespace.ID
    @ViewBuilder let destination: () -> Destination

    var body: some View {
        HStack(alignment: alignment, spacing: 15) {
            if let monthLabel {
                Text(monthLabel)
                    .font(.headingMedium)
                    .foregroundStyle(monthColor)
                    .frame(width: 70, alignment: .leading)
            } else if showMonthGutter {
                Spacer()
                    .frame(width: 70)
            }

            NavigationLink {
                destination()
                    .navigationTransition(.zoom(sourceID: transitionID, in: namespace))
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
            .matchedTransitionSource(id: transitionID, in: namespace)
        }
    }
}

#Preview {
    NavigationStack {
        InvoiceListRowPreviewContainer()
    }
}

private struct InvoiceListRowPreviewContainer: View {
    @Namespace private var namespace

    var body: some View {
        InvoiceListRow(
            monthLabel: "Nov",
            monthColor: .accentDeepOrange,
            alignment: .center,
            vendor: "Wallenstam",
            dueDate: "12-11-2021",
            totalAmount: 5000,
            currency: "SEK",
            trailingIndicator: .none,
            transitionID: "preview",
            namespace: namespace
        ) {
            Text("Destination")
        }
    }
}
