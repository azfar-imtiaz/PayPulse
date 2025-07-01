//
//  CopyTextButton.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-07-02.
//

import SwiftUI

struct CopyTextButton: View {
    let icon: String = "copy-icon"
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Image("copy-icon")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
        }
    }
}

#Preview {
    CopyTextButton(action: {})
}
