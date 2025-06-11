//
//  AuthView.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-06-11.
//

import SwiftUI

struct AuthView: View {
    @State private var showingLogin: Bool = true
    
    var body: some View {
        VStack {
            /// MARK: Auth view header
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Hello")
                    
                    Group {
                        if showingLogin {
                            Text("again! Let's continue.")
                                .id("loginSuffix")
                                .transition(.move(edge: .leading).combined(with: .opacity))
                        } else {
                            Text("newcomer. Let's start!")
                                .id("signupSuffix")
                                .transition(.move(edge: .trailing).combined(with: .opacity))
                        }
                    }
                }
                .foregroundStyle(Color.secondaryDarkGray)
                .font(.custom("Montserrat-Bold", size: 26))
                .animation(.easeInOut(duration: 0.4), value: showingLogin)
                
                Spacer()
            }
            .padding(.leading)
            .padding(.top, 40)
            
            Spacer()
            
            /// MARK: Flipping form card
            ZStack {
                // if showingLogin {
                    // Login form
                    AuthCardView(
                        content: LoginView(toggleAuthView: {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.2)) {
                                showingLogin = false
                            }
                        })
                    )
                    // when showingLogin is true (front), rotation is 0, opacity is 1, zIndex is higher
                    // when showingLogin is false (back), rotation is 180, opacity is 0, zIndex is lower
                    .rotation3DEffect(.degrees(showingLogin ? 0 : 180), axis: (x: 0, y: 1, z: 0), perspective: 0.5)
                    .opacity(showingLogin ? 1 : 0)
                    .zIndex(showingLogin ? 1 : 0) // ensure this card is on top when it's the front
                    .animation(.easeInOut(duration: 0.8), value: showingLogin) // Card flip animation duration
                // } else {
                    // Signup form
                    AuthCardView(
                        content: SignupView(toggleAuthView: {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.2)) {
                                showingLogin = true
                            }
                        })
                    )
                    // When showingLogin is true (back), rotation is -180, opacity is 0, zIndex is lower
                    // When showingLogin is false (front), rotation is 0, opacity is 1, zIndex is higher
                    .rotation3DEffect(.degrees(showingLogin ? -180 : 0), axis: (x: 0, y: 1, z: 0), perspective: 0.5)
                    .opacity(showingLogin ? 0 : 1)
                    .zIndex(showingLogin ? 0 : 1) // ensure this card is on top when it's the front
                    .animation(.easeInOut(duration: 0.8), value: showingLogin) // Card flip animation duration
                // }
            }
            .frame(height: 400)
            
            Spacer()
        }
    }
}

#Preview {
    AuthView()
}
