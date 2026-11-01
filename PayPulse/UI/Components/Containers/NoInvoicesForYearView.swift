//
//  NoInvoicesForYearView.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2026-11-01.
//

import SwiftUI

struct NoInvoicesForYearView: View {
    let year: Int

    var body: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 100)

            Text("No invoices found for \(year.description)")
                .font(.headingStandard)
                .foregroundStyle(Color.secondaryDarkGray)
                .multilineTextAlignment(.center)

            Text("Select a different year or check back later")
                .font(.bodyStandard)
                .foregroundStyle(Color.secondaryDarkGray)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .padding()
    }
}

#Preview {
    NoInvoicesForYearView(year: 2025)
}
