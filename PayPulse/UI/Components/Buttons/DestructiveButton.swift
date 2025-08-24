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
            ZStack(alignment: .center) {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(isDisabled ? .gray : Color.accentDeepRed)
                
                buttonView
                    .font(.buttonLarge)
                    .foregroundStyle(Color.white)
            }
            .frame(width: 300, height: 50)
        }
    }
}

#Preview {
    DestructiveButton(buttonView: Text("Login").bold().foregroundStyle(.white), action: {}, isDisabled: false)
}
