//
//  InvoiceCategoryCard.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2026-02-05.
//

import SwiftUI

struct InvoiceCategoryCard<Destination: View>: View {
    let iconName: String
    let iconTitle: String
    let destination: Destination
    let invoiceCount: Int?

    init(iconName: String, iconTitle: String, destination: Destination, invoiceCount: Int? = nil) {
        self.iconName = iconName
        self.iconTitle = iconTitle
        self.destination = destination
        self.invoiceCount = invoiceCount
    }

    var body: some View {
        NavigationLink {
            destination
        } label: {
            VStack(alignment: .center, spacing: 8) {
                RectangleRoundedCorners(strokeWidth: 2)
                    .frame(width: 130, height: 130)
                    .overlay {
                        Icon(name: iconName, size: 50)
                    }

                Text(iconTitle)
                    .font(.uiLabel)
                    .foregroundStyle(Color.secondaryDarkGray)

                if let count = invoiceCount {
                    Text("\(count) \(count == 1 ? "invoice" : "invoices")")
                        .font(.caption)
                        .foregroundStyle(Color.green)
                        .fontWeight(.medium)
                }
            }
        }
    }
}

#Preview {
    // InvoiceCategoryCard()
}
