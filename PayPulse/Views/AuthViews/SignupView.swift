//
//  SignupView.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-06-11.
//

import SwiftUI

struct SignupView: View {
    @State var name     : String = ""
    @State var email    : String = ""
    @State var password : String = ""
    @State var gmailPassword : String = ""
    
    var toggleAuthView: () -> Void
    
    var body: some View {
        VStack {
            /*
            /// MARK: Auth view header
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Sign up ")
                    Text("with a new account.")
                }
                .foregroundStyle(Color.secondaryDarkGray)
                .font(.custom("Montserrat-Bold", size: 26))
                
                Spacer()
            }
            .padding(.leading)
            .padding(.top, 40)
            
            Spacer()
             */
            
            /// MARK: Signup form
            
            VStack(alignment: .center, spacing: 20) {
                LabeledTextField(
                    text: $name,
                    placeholderText: "Enter your full name",
                    labelText: "Name"
                )
                
                LabeledTextField(
                    text: $email,
                    placeholderText: "Enter your email address",
                    labelText: "Email address"
                )
                
                LabeledTextField(
                    text: $password,
                    placeholderText: "Enter your password",
                    labelText: "Password",
                    isSecure: true
                )
                
                LabeledTextField(
                    text: $gmailPassword,
                    placeholderText: "Enter your Gmail app password",
                    labelText: "Gmail app password (optional)"
                )
                
                PrimaryButton(
                    buttonView: Text("Sign up"),
                    action: {}
                )
                .padding(.top)
                
                HStack(spacing: 0) {
                    Text("Already have an account? ")
                        .font(.custom("Montserrat-Regular", size: 12))
                        .foregroundStyle(Color.secondaryDarkGray)
                    
                    TextButton(
                        buttonText: "Sign in!",
                        textColor: Color.accentColorOrange,
                        font: "Montserrat-Regular",
                        fontSize: 12,
                        isUnderlined: true,
                        action: {
                            toggleAuthView()
                        }
                    )
                }
            }
            
            
            // Spacer()
        }
    }
}

#Preview {
    SignupView(toggleAuthView: {})
}
