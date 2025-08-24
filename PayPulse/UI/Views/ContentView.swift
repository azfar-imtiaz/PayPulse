//
//  ContentView.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2024-11-15.
//

import SwiftUI

struct ContentView: View {
    let invoiceService : InvoiceService
    let userService    : UserService
    
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationStack {
            VStack {
                
                HStack {
                    Text("PayPulse")
                        .font(.custom("Montserrat-Bold", size: 26))
                        .foregroundStyle(Color.secondaryDarkGray)
                    Spacer()
                    NavigationLink {
                        ProfileView()
                    } label: {
                        Utils.getIconColored(colorScheme: colorScheme, iconName: "user")
                    }
                    .padding(.trailing)
                }
                .padding(.leading)
                .padding(.top, 20)
                
                HStack {
                    Text("All your invoices, one place.")
                        // .font(.custom("GothamCond-Medium", size: 24))
                        .font(.custom("Montserrat-Bold", size: 22))
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
                                .font(.custom("Gotham-Book", size: 15))
                                .foregroundStyle(Color.secondaryDarkGray)
                        }                        
                    }
                    Spacer()
                }
                .padding()
                
                Spacer()
            }
            .background(Color.primaryOffWhite)
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
