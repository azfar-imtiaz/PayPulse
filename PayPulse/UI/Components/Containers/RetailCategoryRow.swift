//
//  RetailCategoryRow.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2026-05-27.
//

import SwiftUI

struct RetailCategoryRow<Destination: View>: View {
    let subType: RetailInvoiceSubType
    let invoiceCount: Int
    let destination: Destination

    var body: some View {
        NavigationLink {
            destination
        } label: {
            HStack(spacing: 16) {
                // Soft-tinted icon bubble
                ZStack {
                    Circle()
                        .fill(subType.color.opacity(0.15))
                        .frame(width: 52, height: 52)
                    Image(systemName: subType.sfSymbolName)
                        .font(.headingCompact)
                        .foregroundStyle(subType.color)
                }

                // Category name
                Text(subType.displayName)
                    .font(.bodyLarge)
                    .foregroundStyle(Color.secondaryDarkGray)

                Spacer()

                // Count badge
                Text("\(invoiceCount)")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundStyle(subType.color)
                    .padding(.horizontal, Spacing.sm) // rounded 10->8, compact chip
                    .padding(.vertical, Spacing.xs)
                    .background(
                        Capsule()
                            .fill(subType.color.opacity(0.15))
                    )

                // Disclosure chevron
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.secondaryDarkGray)
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.lg) // rounded 14->16 to match .horizontal above
            .background(
                RoundedRectangle(cornerRadius: Radius.xl)
                    .fill(Color.primaryOffWhite)
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.xl)
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
            RetailCategoryRow(
                subType: .foodDelivery,
                invoiceCount: 24,
                destination: EmptyView()
            )
            RetailCategoryRow(
                subType: .technology,
                invoiceCount: 8,
                destination: EmptyView()
            )
            RetailCategoryRow(
                subType: .miscellaneous,
                invoiceCount: 0,
                destination: EmptyView()
            )
        }
        .padding()
        .background(Color.primaryOffWhite)
    }
}
