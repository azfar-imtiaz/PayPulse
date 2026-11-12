//
//  BaseButton.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2026-11-12.
//

import SwiftUI

struct BaseButton<Content: View, Background: View>: View {
    let buttonView: Content
    let action: () -> Void
    var isDisabled: Bool = false
    var font: Font
    var foregroundColor: Color
    @ViewBuilder var background: Background
    var usesPressScale: Bool = false

    var body: some View {
        let button = Button {
            if !isDisabled {
                action()
            }
        } label: {
            buttonView
                .font(font)
                .foregroundStyle(foregroundColor)
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(background)
                .padding(.horizontal, Spacing.xxl)
        }

        if usesPressScale {
            button.buttonStyle(PressScaleButtonStyle())
        } else {
            button
        }
    }
}
