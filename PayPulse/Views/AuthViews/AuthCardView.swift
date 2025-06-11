//
//  AuthCardView.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-06-11.
//

import SwiftUI

struct AuthCardView<Content: View>: View {
    let content: Content
    
    var body: some View {        
        content
            .padding(25)
            .frame(maxWidth: .infinity)
    }
}

#Preview {
    AuthCardView(
        content: Text("Template")
    )
}
