//
//  BackButton.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2026-11-01.
//

import SwiftUI

struct BackButton: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Button {
            dismiss()
        } label: {
            Utils.getIconColored(colorScheme: colorScheme, iconName: "circle-arrow-left")
        }
    }
}

#Preview {
    BackButton()
}
