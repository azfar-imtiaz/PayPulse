//
//  InputTextField.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-06-09.
//

import SwiftUI

struct InputTextField: View {
    @Binding var text   : String
    var placeholderText : String
    var isEmail         : Bool = false
    var isSecure        : Bool = false
    
    var body: some View {
        ZStack(alignment: .center) {
            RoundedRectangle(cornerRadius: 10)
                .stroke(style: StrokeStyle(lineWidth: 1))
                .foregroundStyle(Color.secondary)
            
            inputField
                .foregroundStyle(Color.secondaryDarkGray)
                .font(.bodyLarge)
                .padding(.leading, 12)
        }
        .frame(width: 300, height: 50)
    }
    
    @ViewBuilder
    private var inputField: some View {
        if isSecure {
            SecureField(placeholderText, text: $text)
        } else {
            if isEmail {
                TextField(placeholderText, text: $text)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
            } else {
                TextField(placeholderText, text: $text)
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        InputTextField(text: .constant(""), placeholderText: "Enter text here...", isSecure: false)
        InputTextField(text: .constant("Plain text"), placeholderText: "Enter text here...", isSecure: false)
        InputTextField(text: .constant(""), placeholderText: "Enter text here...", isSecure: true)
        InputTextField(text: .constant("Secure text"), placeholderText: "Enter text here...", isSecure: true)
    }
}
