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
        Button {
            if !isDisabled {
                action()
            }
        } label: {
            buttonView
                .font(.buttonLarge)
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(
                    RoundedRectangle(cornerRadius: Radius.md)
                        .foregroundStyle(isDisabled ? Color.disabledGray : Color.accentDeepRed)
                )
                .padding(.horizontal, Spacing.xxl)
        }
    }
}

#Preview {
    DestructiveButton(buttonView: Text("Login").bold().foregroundStyle(.white), action: {}, isDisabled: false)
}
