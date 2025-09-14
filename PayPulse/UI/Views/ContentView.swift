//
//  ContentView.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2024-11-15.
//

import SwiftUI
import Toasts

struct ContentView: View {
    let invoiceService : InvoiceService
    let userService    : UserService
    let gmailService   : GmailAuthService
    
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.presentToast) var presentToast
    
    var body: some View {
        NavigationStack {
            VStack {
                
                HStack {
                    Text("PayPulse")
                        .font(.headingLarge)
                        .foregroundStyle(Color.secondaryDarkGray)
                    Spacer()
                    NavigationLink {
                        ProfileView(userService: userService, gmailService: gmailService)
                    } label: {
                        Utils.getIconColored(colorScheme: colorScheme, iconName: "user")
                    }
                    .padding(.trailing)
                }
                .padding(.leading)
                .padding(.top, 20)
                
                HStack {
                    Text("All your invoices, one place.")
                        // .font(.headingMedium)
                        .font(.headingStandard)
                        .foregroundStyle(.gray)
                    
                    Spacer()
                }
                .padding([.leading, .bottom])
                
                HStack {
                    NavigationLink {
                        RentalLandingPage(invoiceService: invoiceService)
                    } label: {
                        VStack(alignment: .center) {
                            RectangleRoundedCorners(strokeWidth: 2)
                                .frame(width: 130, height: 130)
                                .overlay {
                                    Icon(name: "file-spreadsheet", size: 50)
                                }
                            
                            Text("Rental invoices")
                                .font(.uiLabel)
                                .foregroundStyle(Color.secondaryDarkGray)
                        }                        
                    }
                    Spacer()
                }
                .padding()
                
                Spacer()
            }
            .background(Color.primaryOffWhite)
            .onAppear {
                // Check for pending welcome toast and login context
                if let pendingToast = authManager.pendingToast,
                   let loginContext = authManager.loginContext,
                   loginContext != .keychain {
                    // Only show toast for login and signup, not keychain authentication
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        presentToast(pendingToast)
                        authManager.clearPendingToast()
                        authManager.clearLoginContext()
                    }
                }
            }
        }
    }
    
    private func getIconNameColored(iconName: String) -> String {
        if colorScheme == .dark {
            return "\(iconName)-light"
        } else {
            return "\(iconName)-dark"
        }
    }
}

#Preview {
    // ContentView()
    //     .preferredColorScheme(.dark)
}
