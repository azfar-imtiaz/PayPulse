//
//  LabeledTextField.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-06-10.
//

import SwiftUI

struct LabeledTextField: View {
    @Binding var text   : String
    var placeholderText : String
    var labelText       : String
    var isSecure        : Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(labelText)
                .foregroundStyle(Color.secondaryDarkGray)
                .font(.formLabel)
                .padding(.leading, 12)
            
            InputTextField(text: $text, placeholderText: placeholderText, isSecure: isSecure)
        }
    }
}

#Preview {
    LabeledTextField(text: .constant("Text"), placeholderText: "Placeholder text", labelText: "Text field label")
}
