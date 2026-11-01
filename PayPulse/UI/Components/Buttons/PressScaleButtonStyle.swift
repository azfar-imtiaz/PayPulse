//
//  PressScaleButtonStyle.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2026-11-01.
//

import SwiftUI

struct PressScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}
