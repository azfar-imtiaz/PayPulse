//
//  CopyTextButton.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-07-02.
//

import SwiftUI

struct CopyTextButton: View {
    let icon: String = "copy"
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Icon(name: icon)
        }
    }
}

#Preview {
    CopyTextButton(action: {})
}
