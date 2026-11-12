//
//  InvoiceDetailsContainer.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-07-02.
//

import SwiftUI

struct InvoiceDetailsContainer<Content: View>: View {
    var borderOpacity: CGFloat = 1.0
    @ViewBuilder let invoiceDetailsView: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            invoiceDetailsView
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: Radius.sm)
                .fill(Color.white)
                /*
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.sm)
                        .stroke(Color.secondaryDarkGray.opacity(borderOpacity), lineWidth: 1)
                )
                 */
        )
        .shadow(color: Color.black.opacity(0.06), radius: 1, x: 0, y: 1)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 6)
    }
}

#Preview {
    InvoiceDetailsContainer {
        InvoiceSummary(
            vendor: "Wallenstam",
            dueDate: "12-11-2021",
            totalAmount: 5000
        )
    }
    .padding(.horizontal)
}
