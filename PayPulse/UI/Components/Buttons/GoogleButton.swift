//
//  GoogleButton.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-09-09.
//

import SwiftUI

struct GoogleButton: View {
    var connectToGmailAction: () -> Void
    
    var body: some View {
        SecondaryButton(
            buttonView: HStack {
                Image("google-logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                
                Text("Continue with Google")
            },
            action: {
                connectToGmailAction()
            }
        )
    }
}

#Preview {
    GoogleButton(connectToGmailAction: {})
}
