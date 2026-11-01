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
                        .foregroundStyle(isDisabled ? Color.disabledGray : Color.accent)
                )
                .padding(.horizontal, Spacing.xxl)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        PrimaryButton(buttonView: Text("Login").bold().foregroundStyle(.white), action: {}, isDisabled: false)
        PrimaryButton(buttonView: Text("Login").bold().foregroundStyle(.white), action: {}, isDisabled: true)
    }
}
