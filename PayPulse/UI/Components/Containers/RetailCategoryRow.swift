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
                        .font(.system(size: 22, weight: .medium))
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
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(subType.color.opacity(0.15))
                    )

                // Disclosure chevron
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.primaryOffWhite)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.secondaryDarkGray.opacity(0.15), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
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
