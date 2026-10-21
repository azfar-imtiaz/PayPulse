//
//  InvoiceDetailSection.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2026-10-21.
//

import SwiftUI

/// Pairs a section heading with its content so they can never be shown out of sync -
/// if `isVisible` is false, neither the heading nor the content is rendered.
struct InvoiceDetailSection<Content: View>: View {
    let title: String
    let isVisible: Bool
    @ViewBuilder let content: () -> Content

    var body: some View {
        if isVisible {
            VStack(alignment: .leading, spacing: 20) {
                Text(title)
                    .font(.bodyLarge)
                    .foregroundStyle(Color.secondaryDarkGray)
                    .padding(.horizontal)

                content()
                    .padding(.horizontal)
            }
        }
    }
}
