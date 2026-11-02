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
    @Namespace private var recentActivityNamespace

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
                        .foregroundStyle(.gray)

                    Spacer()
                }
                .padding([.leading, .bottom])

                ScrollView {
                    VStack(spacing: 12) {
                        summaryCard

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

                        if !recentRentalInvoices.isEmpty {
                            recentActivitySection
                        }
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

    // Retail isn't included yet: ContentView only fetches retail invoice *counts*
    // on launch, not amounts, so a true combined total needs a backend endpoint
    // for month-based retail totals before it can be added here.
    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 4) {
            if rentalViewModel.invoicesHaveLoaded {
                if currentMonthRentalTotal > 0 {
                    Text(Utils.formatCurrency(Double(currentMonthRentalTotal), currency: "SEK"))
                        .font(.headingMedium)
                        .foregroundStyle(Color.accentDeepOrange)
                } else {
                    Text("Invoice not available yet")
                        .font(.headingMedium)
                        .foregroundStyle(Color.accentDeepOrange)
                }
            } else {
                Text("-")
                    .font(.headingMedium)
                    .foregroundStyle(Color.accentDeepOrange)
            }
            Text("This month's rent")
                .font(.bodyStandard)
                .foregroundStyle(Color.secondaryDarkGray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.xl)
        .background(
            RoundedRectangle(cornerRadius: Radius.xl)
                .fill(Color.primaryOffWhite)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.xl)
                        .stroke(Color.secondaryDarkGray.opacity(0.15), lineWidth: 1)
                )
        )
    }

    // Retail isn't included yet for the same reason as the summary card -
    // only counts are fetched for retail today, not full invoice data.
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Recent rental invoices")
                .font(.bodyLarge)
                .foregroundStyle(Color.secondaryDarkGray)
                .padding(.top, Spacing.sm)

            ForEach(recentRentalInvoices, id: \.invoiceID) { invoice in
                InvoiceListRow(
                    monthLabel: invoice.getDueMonthName(),
                    monthColor: .accentDeepOrange,
                    alignment: .center,
                    vendor: "Wallenstam",
                    dueDate: invoice.dueDate,
                    totalAmount: invoice.totalAmount,
                    currency: "SEK",
                    trailingIndicator: .statusBadge,
                    transitionID: "home_recent_\(invoice.invoiceID)",
                    namespace: recentActivityNamespace
                ) {
                    RentalDetailsView(invoice: invoice)
                }
            }
        }
    }

    private var recentRentalInvoices: [RentalInvoice] {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")

        return rentalViewModel.invoices.values
            .flatMap { $0 }
            .sorted { lhs, rhs in
                let lhsDate = formatter.date(from: lhs.dueDate) ?? .distantPast
                let rhsDate = formatter.date(from: rhs.dueDate) ?? .distantPast
                return lhsDate > rhsDate
            }
            .prefix(5)
            .map { $0 }
    }

    private var currentMonthRentalTotal: Int {
        rentalViewModel.invoices.values
            .flatMap { $0 }
            .filter { $0.isDueInCurrentMonth() }
            .reduce(0) { $0 + $1.totalAmount }
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
