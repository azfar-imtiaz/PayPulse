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
            ZStack(alignment: .center) {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(isDisabled ? .gray : Color.accent)
                
                buttonView
                    .font(.custom("Gotham-Bold", size: 18))
            }
            .frame(width: 300, height: 50)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        PrimaryButton(buttonView: Text("Login").bold().foregroundStyle(.white), action: {}, isDisabled: false)
        PrimaryButton(buttonView: Text("Login").bold().foregroundStyle(.white), action: {}, isDisabled: true)
    }
}
