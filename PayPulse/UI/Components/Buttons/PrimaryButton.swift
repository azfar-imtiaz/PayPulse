//
//  PrimaryButton.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-06-08.
//

import SwiftUI

struct PrimaryButton<Content: View>: View {
    let buttonView : Content
    let action     : () -> Void
    var isDisabled : Bool = false

    var body: some View {
        BaseButton(
            buttonView: buttonView,
            action: action,
            isDisabled: isDisabled,
            font: .buttonLarge,
            foregroundColor: Color.white,
            background: {
                RoundedRectangle(cornerRadius: Radius.md)
                    .foregroundStyle(isDisabled ? Color.disabledGray : Color.accent)
            }
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        PrimaryButton(buttonView: Text("Login").bold().foregroundStyle(.white), action: {}, isDisabled: false)
        PrimaryButton(buttonView: Text("Login").bold().foregroundStyle(.white), action: {}, isDisabled: true)
    }
}
