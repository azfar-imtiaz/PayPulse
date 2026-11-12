//
//  SecondaryButton.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-06-08.
//

import SwiftUI

struct SecondaryButton<Content: View>: View {
    let buttonView: Content
    let action: () -> Void

    var body: some View {
        BaseButton(
            buttonView: buttonView,
            action: action,
            font: .buttonStandard,
            foregroundColor: Color.secondaryDarkGray,
            background: {
                RoundedRectangle(cornerRadius: Radius.md)
                    .stroke(style: StrokeStyle(lineWidth: 1))
                    .foregroundStyle(Color.secondaryDarkGray)
            }
        )
    }
}

#Preview {
    SecondaryButton(
        buttonView: Text("Sign up"),
        action: {}
    )
}
