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

    @StateObject private var rentalViewModel : RentalInvoicesViewModel
    @StateObject private var retailViewModel : RetailInvoicesViewModel

    @EnvironmentObject var authManager: AuthManager
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.presentToast) var presentToast

    init(invoiceService: InvoiceService, userService: UserService, gmailService: GmailAuthService) {
        self.invoiceService = invoiceService
        self.userService = userService
        self.gmailService = gmailService
        _rentalViewModel = StateObject(wrappedValue: RentalInvoicesViewModel(invoiceService: invoiceService))
        _retailViewModel = StateObject(wrappedValue: RetailInvoicesViewModel(invoiceService: invoiceService))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

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

                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 20) {
                        InvoiceCategoryCard(
                            iconName: "house",
                            iconTitle: "Rental Invoices",
                            destination: RentalLandingPage(
                                invoiceService: invoiceService,
                                viewModel: rentalViewModel
                            ),
                            invoiceCount: rentalViewModel.invoicesHaveLoaded
                                ? rentalViewModel.invoices.values.flatMap { $0 }.count
                                : nil
                        )

                        InvoiceCategoryCard(
                            iconName: "file-spreadsheet",
                            iconTitle: "Retail Invoices",
                            destination: RetailLandingPage(
                                invoiceService: invoiceService,
                                viewModel: retailViewModel
                            ),
                            invoiceCount: retailViewModel.countsHaveLoaded
                                ? retailViewModel.getTotalCount()
                                : nil
                        )
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 20)
                }
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
                fetchInvoiceCounts()
            }
        }
    }

    private func fetchInvoiceCounts() {
        if !rentalViewModel.invoicesHaveLoaded {
            Task {
                try? await rentalViewModel.getInvoices()
                rentalViewModel.invoicesHaveLoaded = true
            }
        }
        if !retailViewModel.countsHaveLoaded {
            Task {
                try? await retailViewModel.getInvoiceCounts()
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
