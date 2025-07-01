//
//  InvoiceDetailsContainer.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-07-02.
//

import SwiftUI

struct InvoiceDetailsContainer<Content: View>: View {
    @ViewBuilder let invoiceDetailsView: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            invoiceDetailsView
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.secondaryDarkGray, lineWidth: 1)
        )
    }
}

#Preview {
    InvoiceDetailsContainer {
        VStack {
            Text("Heading")
            Spacer()
            Text("Normal text")
        }
    }
}
