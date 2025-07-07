//
//  AuthView.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-06-11.
//

import SwiftUI

struct AuthView: View {
    let authService: AuthService
    
    @State private var showingLogin : Bool = true
    @State var isLoading            : Bool = false
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        ZStack(alignment: .center) {
            VStack {
                
                /// MARK: Auth view header
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("PayPulse. Smart")
                        
                        Group {
                            if showingLogin {
                                Text("connections. Log in.")
                                    .id("loginSuffix")
                                    .transition(.move(edge: .leading).combined(with: .opacity))
                            } else {
                                Text("automation. Join us.")
                                    .id("signupSuffix")
                                    .transition(.move(edge: .trailing).combined(with: .opacity))
                            }
                        }
                        .foregroundStyle(Color.gray)
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
                    // Login form
                    AuthCard(
                        content: LoginView(
                            authService: authService,
                            toggleAuthView: {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.2)) {
                                    showingLogin = false
                                }
                            },
                            isLoading: $isLoading
                        )
                    )
                    // when showingLogin is true (front), rotation is 0, opacity is 1, zIndex is higher
                    // when showingLogin is false (back), rotation is 180, opacity is 0, zIndex is lower
                    .rotation3DEffect(.degrees(showingLogin ? 0 : 180), axis: (x: 0, y: 1, z: 0), perspective: 0.5)
                    .opacity(showingLogin ? 1 : 0)
                    .zIndex(showingLogin ? 1 : 0) // ensure this card is on top when it's the front
                    .animation(.easeInOut(duration: 0.4), value: showingLogin) // Card flip animation duration
                    
                    // Signup form
                    AuthCard(
                        content: SignupView(
                            authService: authService,
                            toggleAuthView: {
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
                    .animation(.easeInOut(duration: 0.4), value: showingLogin) // Card flip animation duration
                }
                
                Spacer()
            }
            
            LoadingDotsView(isLoading: $isLoading, loadingText: showingLogin ? "Logging in..." : "Signing up...")
        }
        .background(Color.primaryOffWhite)
    }
}

/*
#Preview {
    AuthView(authService: AuthService(apiClient: nil, authManager: nil))
}
*/
