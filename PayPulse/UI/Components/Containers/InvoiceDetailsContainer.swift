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
            RectangleRoundedCorners(color: Color.secondaryDarkGray.opacity(borderOpacity))
        )
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
}
