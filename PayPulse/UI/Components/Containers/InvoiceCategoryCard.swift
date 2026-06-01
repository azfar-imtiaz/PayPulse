//
//  InvoiceCategoryCard.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2026-02-05.
//

import SwiftUI

private struct PressScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

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
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.secondaryDarkGray.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.secondaryDarkGray.opacity(0.15), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
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
        .buttonStyle(PressScaleButtonStyle())
    }
}

#Preview {
    // InvoiceCategoryCard()
}
