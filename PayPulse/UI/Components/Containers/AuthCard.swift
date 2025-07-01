//
//  AuthCardView.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-06-11.
//

import SwiftUI

struct AuthCard<Content: View>: View {
    let content: Content
    
    var body: some View {        
        content
            .padding(25)
            .frame(maxWidth: .infinity)
    }
}

#Preview {
    AuthCard(
        content: Text("Template")
    )
}
