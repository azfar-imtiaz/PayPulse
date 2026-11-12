//
//  SoftButton.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2026-11-02.
//

import SwiftUI

struct SoftButton<Content: View>: View {
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
                    .fill(Color.primaryOffWhite)
                    .shadow(color: Color.black.opacity(0.08), radius: 2, x: 0, y: 1)
            },
            usesPressScale: true
        )
    }
}

#Preview {
    SoftButton(buttonView: Text("Log out"), action: {})
        .padding()
        .background(Color.secondaryDarkGray.opacity(0.1))
}
