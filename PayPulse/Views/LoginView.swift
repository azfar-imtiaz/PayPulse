//
//  LoginView.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-06-09.
//

import SwiftUI

struct LoginView: View {
    @State var email    : String = ""
    @State var password : String = ""
    
    var body: some View {
        VStack {
            /// MARK: Auth view header
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Login with")
                    Text("your existing account.")
                }
                .foregroundStyle(Color.secondaryDarkGray)
                .font(.custom("Montserrat-Bold", size: 26))
                
                Spacer()
            }
            .padding(.leading)
            .padding(.top, 40)
            
            Spacer()
            
            /// MARK: Login form
            
            VStack(alignment: .center, spacing: 20) {
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
                
                PrimaryButton(
                    buttonView: Text("Login"),
                    action: {}
                )
                .padding(.top)
                
                HStack(spacing: 0) {
                    Text("No account? Let's ")
                        .font(.custom("Montserrat-Regular", size: 12))
                        .foregroundStyle(Color.secondaryDarkGray)
                    
                    TextButton(
                        buttonText: "create one!",
                        textColor: Color.accentColorOrange,
                        font: "Montserrat-Regular",
                        fontSize: 12,
                        isUnderlined: true,
                        action: {}
                    )
                }
                
                HStack(spacing: 10) {
                    HorizontalLine()
                    
                    Text("OR")
                        .font(.custom("Montserrat-Regular", size: 12))
                    
                    HorizontalLine()
                }
                .foregroundStyle(Color.secondaryDarkGray)
                .frame(width: 250)
                .padding(.horizontal)
                
                SecondaryButton(
                    buttonView: HStack {
                        Image("google-logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                        
                        Text("Continue with Google")
                    },
                    action: {}
                )
            }
            
            
            Spacer()
        }
    }
}

#Preview {
    LoginView()
}
