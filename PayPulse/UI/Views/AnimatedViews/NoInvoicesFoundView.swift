//
//  NoInvoicesFoundView.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-08-10.
//

import SwiftUI
import Lottie

struct NoInvoicesFoundView: View {
    var title                : String = "No invoices found!"
    var subtitle             : String
    var showAnimation        : Bool = true
    @Binding var showSpinner : Bool     // needed in order to set the disabled status on the "Load invoices" button
    var loadInvoicesAction   : (() async throws -> Void)?

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            if showAnimation {
                LottieView(animation: .named("empty"))
                    .playing(loopMode: .loop)
                    .frame(height: 300)
            }

            Group {
                Text(title)
                    .font(.buttonStandard)

                Text(subtitle)
                    .font(.bodyStandard)
            }
            .foregroundStyle(Color.secondaryText)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, Spacing.xxl)

            if let loadInvoicesAction {
                PrimaryButton(
                    buttonView: Text("Load invoices"),
                    action: {
                        Task {
                            try await loadInvoicesAction()
                        }
                    },
                    isDisabled: showSpinner
                )
            }

            Spacer()
        }
        .background(Color.primarySurface)
    }
}

#Preview {
    NoInvoicesFoundView(subtitle: "Click the button below to fetch rental invoices from your inbox.", showSpinner: .constant(false)) {

    }
}

#Preview {
    NoInvoicesFoundView(
        title: "No invoices found for 2025",
        subtitle: "Select a different year or check back later",
        showAnimation: false,
        showSpinner: .constant(false)
    )
}
