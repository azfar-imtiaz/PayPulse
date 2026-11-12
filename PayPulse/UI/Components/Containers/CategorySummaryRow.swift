//
//  CategorySummaryRow.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2026-11-02.
//

import SwiftUI

struct CategorySummaryRow<Icon: View, Destination: View>: View {
    let iconColor: Color
    @ViewBuilder let icon: Icon
    let title: String
    let count: Int?
    let destination: Destination

    var body: some View {
        NavigationLink {
            destination
        } label: {
            HStack(spacing: 16) {
                // Soft-tinted icon bubble
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 52, height: 52)
                    icon
                }

                // Category name
                Text(title)
                    .font(.bodyLarge)
                    .foregroundStyle(Color.secondaryDarkGray)

                Spacer()

                // Count badge
                if let count {
                    Text("\(count)")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundStyle(iconColor)
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, Spacing.xs)
                        .background(
                            Capsule()
                                .fill(iconColor.opacity(0.15))
                        )
                } else {
                    ProgressView()
                        .scaleEffect(0.7)
                }

                // Disclosure chevron
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.secondaryDarkGray)
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: Radius.sm)
                    .fill(Color.primaryOffWhite)
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.sm)
                            .stroke(Color.secondaryDarkGray.opacity(0.15), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PressScaleButtonStyle())
    }
}

#Preview {
    NavigationStack {
        VStack(spacing: 12) {
            CategorySummaryRow(
                iconColor: RetailInvoiceSubType.foodDelivery.color,
                icon: {
                    Image(systemName: RetailInvoiceSubType.foodDelivery.sfSymbolName)
                        .font(.headingCompact)
                        .foregroundStyle(RetailInvoiceSubType.foodDelivery.color)
                },
                title: RetailInvoiceSubType.foodDelivery.displayName,
                count: 24,
                destination: EmptyView()
            )
            CategorySummaryRow(
                iconColor: Color.accentDeepOrange,
                icon: {
                    Icon(name: "house", size: 24, color: .accentDeepOrange)
                },
                title: "Rental Invoices",
                count: nil,
                destination: EmptyView()
            )
        }
        .padding()
        .background(Color.primaryOffWhite)
    }
}
