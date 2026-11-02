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
    let outlookService : OutlookAuthService

    @StateObject private var rentalViewModel : RentalInvoicesViewModel
    @StateObject private var retailViewModel : RetailInvoicesViewModel

    @EnvironmentObject var authManager: AuthManager
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.presentToast) var presentToast

    init(invoiceService: InvoiceService, userService: UserService, gmailService: GmailAuthService, outlookService: OutlookAuthService) {
        self.invoiceService = invoiceService
        self.userService = userService
        self.gmailService = gmailService
        self.outlookService = outlookService
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
                        ProfileView(userService: userService, gmailService: gmailService, outlookService: outlookService)
                    } label: {
                        Utils.getIconColored(colorScheme: colorScheme, iconName: "user")
                    }
                    .padding(.trailing)
                }
                .padding(.leading)
                .padding(.top, Spacing.xl)

                HStack {
                    Text("All your invoices, one place.")
                        .font(.headingStandard)
                        .foregroundStyle(Color.secondaryDarkGray)

                    Spacer()
                }
                .padding([.leading, .bottom])

                ScrollView {
                    VStack(spacing: 12) {
                        // Reserved slot for a future Scan button - inert for now
                        scanSlot

                        CategorySummaryRow(
                            iconColor: Color.accentDeepOrange,
                            icon: {
                                Icon(name: "house", size: 24, color: .accentDeepOrange)
                            },
                            title: "Rental Invoices",
                            count: rentalViewModel.invoicesHaveLoaded
                                ? rentalViewModel.invoices.values.flatMap { $0 }.count
                                : nil,
                            destination: RentalLandingPage(
                                invoiceService: invoiceService,
                                viewModel: rentalViewModel
                            )
                        )

                        CategorySummaryRow(
                            iconColor: Color.accentDeepRed,
                            icon: {
                                Icon(name: "file-spreadsheet", size: 24, color: .accentDeepRed)
                            },
                            title: "Retail Invoices",
                            count: retailViewModel.countsHaveLoaded
                                ? retailViewModel.getTotalCount()
                                : nil,
                            destination: RetailLandingPage(
                                invoiceService: invoiceService,
                                viewModel: retailViewModel
                            )
                        )
                    }
                    .padding(.horizontal)
                    .padding(.vertical, Spacing.xl)
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

    // Reserved for a future Scan button - intentionally inert, no action wired yet.
    private var scanSlot: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.disabledGray.opacity(0.15))
                    .frame(width: 52, height: 52)
                Image(systemName: "camera.fill")
                    .font(.headingCompact)
                    .foregroundStyle(Color.disabledGray)
            }

            Text("Scan Invoice")
                .font(.bodyLarge)
                .foregroundStyle(Color.disabledGray)

            Spacer()

            Text("Soon")
                .font(.footnote)
                .fontWeight(.semibold)
                .foregroundStyle(Color.disabledGray)
                .padding(.horizontal, Spacing.sm)
                .padding(.vertical, Spacing.xs)
                .background(
                    Capsule()
                        .fill(Color.disabledGray.opacity(0.15))
                )
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: Radius.xl)
                .fill(Color.primaryOffWhite)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.xl)
                        .stroke(Color.disabledGray.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                )
        )
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
