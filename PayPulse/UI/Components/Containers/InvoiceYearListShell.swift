//
//  InvoiceYearListShell.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2026-11-12.
//

import SwiftUI

struct InvoiceYearListShell<Content: View>: View {
    let years: [Int]
    @Binding var selectedYear: Int
    @ViewBuilder let content: Content

    var body: some View {
        VStack {
            HeaderYears(
                years: years,
                selectedYear: $selectedYear
            )
            .padding(.horizontal)
            .padding(.bottom, Spacing.xl)

            content
        }
        .background(Color.invoiceHeaderBannerBackground)
    }
}
