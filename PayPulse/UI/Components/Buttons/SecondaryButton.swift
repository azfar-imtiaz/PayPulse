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
                RoundedRectangle(cornerRadius: 10)
                    .stroke(style: StrokeStyle(lineWidth: 1))
                    .foregroundStyle(Color.secondary)
                
                buttonView
                    .font(.buttonStandard)
                    .foregroundStyle(Color.secondaryDarkGray)
            }
            .frame(width: 300, height: 50)
        }
    }
}

#Preview {
    SecondaryButton(
        buttonView: Text("Sign up"),
        action: {}
    )
}
