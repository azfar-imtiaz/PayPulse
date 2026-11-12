//
//  CopyTextButton.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-07-02.
//

import SwiftUI

struct CopyTextButton: View {
    let icon: String = "copy"
    var size: CGFloat = 20
    var color: Color = Color.accentDeepOrange
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Icon(name: icon, size: size, color: color)
        }
    }
}

#Preview {
    CopyTextButton(action: {})
}
