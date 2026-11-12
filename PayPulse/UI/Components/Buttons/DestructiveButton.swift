//
//  DestructiveButton.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-08-24.
//

import SwiftUI

struct DestructiveButton<Content: View>: View {
    let buttonView: Content
    let action: () -> Void
    var isDisabled: Bool = false

    var body: some View {
        BaseButton(
            buttonView: buttonView,
            action: action,
            isDisabled: isDisabled,
            font: .buttonLarge,
            foregroundColor: Color.white,
            background: {
                RoundedRectangle(cornerRadius: Radius.md)
                    .foregroundStyle(isDisabled ? Color.disabledGray : Color.accentDeepRed)
            }
        )
    }
}

#Preview {
    DestructiveButton(buttonView: Text("Login").bold().foregroundStyle(.white), action: {}, isDisabled: false)
}
