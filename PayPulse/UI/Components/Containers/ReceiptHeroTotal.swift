//
//  ReceiptHeroTotal.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2026-11-02.
//

import SwiftUI

struct ReceiptHeroTotal: View {
    let amount: Int
    let currency: String
    var showCopyButton: Bool = false
    var copyButtonAction: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: Spacing.sm) {
            Text(Utils.formatCurrency(Double(amount), currency: currency))
                .font(.headingLarge)
                .foregroundStyle(Color.accentDeepOrange)
                .monospacedDigit()

            if showCopyButton, let copyButtonAction {
                CopyTextButton(action: copyButtonAction)
            }
        }
    }
}

#Preview {
    ReceiptHeroTotal(amount: 12500, currency: "SEK", showCopyButton: true, copyButtonAction: {})
        .padding()
}
