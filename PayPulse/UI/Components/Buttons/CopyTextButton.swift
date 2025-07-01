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
            Icon(name: "copy-icon")
        }
    }
}

#Preview {
    CopyTextButton(action: {})
}
