//
//  ToggleChip.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2026-11-13.
//

import SwiftUI

/// Small capsule toggle used under the Home and Rental trend graphs.
struct ToggleChip: View {
    let title: String
    let systemImage: String
    @Binding var isOn: Bool
    var tint: Color = .accentDeepOrange

    var body: some View {
        Button {
            withAnimation(.snappy) { isOn.toggle() }
        } label: {
            Label(title, systemImage: systemImage)
                .font(.chipLabel)
                .foregroundStyle(isOn ? tint : Color.secondaryText.opacity(0.7))
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                .background(
                    Capsule()
                        .fill(isOn ? tint.opacity(0.14) : Color.secondaryText.opacity(0.06))
                )
                .overlay(
                    Capsule()
                        .stroke(isOn ? tint.opacity(0.35) : Color.clear, lineWidth: 1)
                )
        }
        .buttonStyle(PressScaleButtonStyle())
        .sensoryFeedback(.selection, trigger: isOn)
        .accessibilityAddTraits(isOn ? .isSelected : [])
    }
}
