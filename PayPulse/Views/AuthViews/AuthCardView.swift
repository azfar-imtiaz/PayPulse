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
        
        RoundedRectangle(cornerRadius: 10)
            .frame(height: UIScreen.main.bounds.height * 0.65)
            .padding(25)
            .foregroundStyle(.white)
            .shadow(color: Color.black.opacity(0.15), radius: 15, x: 0, y: 10)
            .overlay {
                content
            }
    }
}

#Preview {
    AuthCardView(
        content: Text("Template")
    )
}
