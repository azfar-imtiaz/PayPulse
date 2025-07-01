//
//  ContentView.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2024-11-15.
//

import SwiftUI

struct ContentView: View {
    let invoiceService: InvoiceService
    let userService: UserService
    
    var body: some View {
        NavigationStack {
            VStack {
                
                HStack {
                    Text("All your invoices, one place.")
                        .font(.custom("GothamCond-Medium", size: 24))
                        .foregroundStyle(.gray)
                        .font(.title2)
                    
                    Spacer()
                }
                .padding([.leading, .bottom])
                
                HStack {
                    NavigationLink {
                        RentalLandingPage(invoiceService: invoiceService)
                    } label: {
                        VStack(alignment: .center) {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.secondaryDarkGray, lineWidth: 2)
                                .frame(width: 130, height: 130)
                                .overlay {
                                    Image("invoice-icon")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .foregroundStyle(Color.accentDeepOrange)
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
            .navigationTitle("PayPulse")
            .navigationBarTitleDisplayMode(.large)
//            .toolbar {
//                ToolbarItem(placement: .topBarLeading) {
//                    Image("PayPulse-logo")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 70, height: 70, alignment: .leading)
//                }
//            }
        }
    }
}

#Preview {
    // ContentView()
    //     .preferredColorScheme(.dark)
}
