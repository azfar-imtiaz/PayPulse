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
        Button {
            action()
        } label: {
            ZStack(alignment: .center) {
                RoundedRectangle(cornerRadius: Radius.md)
                    .stroke(style: StrokeStyle(lineWidth: 1))
                    .foregroundStyle(Color.secondaryDarkGray)
                
                buttonView
                    .font(.buttonStandard)
                    .foregroundStyle(Color.secondaryDarkGray)
            }
            .frame(maxWidth: .infinity, minHeight: 50)
            .padding(.horizontal, Spacing.xxl)
        }
    }
}

#Preview {
    SecondaryButton(
        buttonView: Text("Sign up"),
        action: {}
    )
}
