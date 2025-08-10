//
//  NoInvoicesFoundView.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-08-10.
//

import SwiftUI
import Lottie

struct NoInvoicesFoundView: View {
    @Binding var showSpinner : Bool     // needed in order to set the disabled status on the "Load invoices" button
    var loadInvoicesAction   : () async throws -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            LottieView(animation: .named("empty"))
                .playing(loopMode: .loop)
                .frame(height: 300)
            
            Group {
                Text("No invoices found!")
                    .font(.custom("Montserrat-SemiBold", size: 16))
                
                Text("Click the button below to fetch rental invoices from your inbox.")
                    .font(.custom("Montserrat-Regular", size: 14))
            }
            .foregroundStyle(Color.secondaryDarkGray)
            .multilineTextAlignment(.center)
            .frame(width: 300)
                
            
            PrimaryButton(
                buttonView: Text("Load invoices"),
                action: {
                    Task {
                        try await loadInvoicesAction()
                    }
                },
                isDisabled: showSpinnerUI/Views/RentalInvoiceViews/RentalListView.swift
            )
            
            Spacer()
        }
        .background(Color.primaryOffWhite)
    }
}

#Preview {
    NoInvoicesFoundView(showSpinner: .constant(false)) {
        
    }
}
