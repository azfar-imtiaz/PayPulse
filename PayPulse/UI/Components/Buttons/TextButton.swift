//
//  TextButton.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-06-10.
//

import SwiftUI

struct TextButton: View {
    var buttonText   : String
    var textColor    : Color = .secondaryDarkGray
    var font         : Font = .bodySmall
    var isUnderlined : Bool = false
    var action       : () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Text(buttonText)
                .foregroundStyle(textColor)
                .font(font)
                .underline(isUnderlined)
        }
    }
}

#Preview {
    TextButton(buttonText: "Button text", action: {})
}
