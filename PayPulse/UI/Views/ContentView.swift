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
    @StateObject private var homeViewModel : HomeViewModel
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
        _homeViewModel = StateObject(wrappedValue: HomeViewModel(invoiceService: invoiceService))
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

                        if !homeViewModel.recentInvoices.isEmpty {
                            recentActivitySection
                                .padding(.top, Spacing.md)
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

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 4) {
            if homeViewModel.summaryHasLoaded {
                Text(Utils.formatCurrency(currentMonthCombinedTotal, currency: "SEK"))
                    .font(.headingMedium)
                    .foregroundStyle(Color.accentDeepOrange)
            } else {
                Text("-")
                    .font(.headingMedium)
                    .foregroundStyle(Color.accentDeepOrange)
            }
            Text("This month's spending")
                .font(.bodyStandard)
                .foregroundStyle(Color.secondaryDarkGray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.xl)
        .background(
            RoundedRectangle(cornerRadius: Radius.sm)
                .fill(Color.invoiceCardBackground)
        )
        .shadow(color: Color.black.opacity(0.06), radius: 1, x: 0, y: 1)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 6)
    }

    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text("Recent invoices")
                .font(.headingSmall)
                .fontWeight(.semibold)
                .foregroundStyle(Color.secondaryDarkGray)
                .padding(.top, Spacing.sm)

            VStack(spacing: Spacing.md) {
                ForEach(homeViewModel.recentInvoices) { item in
                    InvoiceListRow(
                        monthLabel: nil,
                        monthColor: .accentDeepOrange,
                        alignment: .center,
                        showMonthGutter: false,
                        vendor: item.vendorName ?? "Wallenstam",
                        dueDate: item.getFormattedDueDate(),
                        totalAmount: Int(item.totalAmount.rounded()),
                        currency: item.currency ?? "SEK",
                        trailingIndicator: .statusBadge,
                        transitionID: "home_recent_\(item.invoiceID)",
                        namespace: recentActivityNamespace
                    ) {
                        recentItemDestination(for: item)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func recentItemDestination(for item: InvoiceSummaryItem) -> some View {
        switch item.invoiceType {
        case .rental:
            if let fullInvoice = rentalViewModel.invoices.values.flatMap({ $0 }).first(where: { $0.invoiceID == item.invoiceID }) {
                RentalDetailsView(invoice: fullInvoice)
            } else {
                RentalDetailsView(invoice: RentalInvoice(
                    invoiceID: item.invoiceID,
                    filename: "",
                    hyra: Int(item.totalAmount.rounded()),
                    el: -1,
                    kallvatten: -1,
                    varmvatten: -1,
                    totalAmount: Int(item.totalAmount.rounded()),
                    dueDateMonth: "",
                    dueDateYear: "",
                    dueDate: item.getFormattedDueDate(),
                    moms: -1,
                    ocr: ""
                ))
            }
        case .retail:
            RetailInvoiceDetailView(
                invoice: RetailInvoiceBase(
                    invoiceID: item.invoiceID,
                    invoiceDate: item.invoiceDate,
                    totalAmount: item.totalAmount,
                    currency: item.currency,
                    vendorName: item.vendorName ?? ""
                ),
                subType: item.subType.flatMap { RetailInvoiceSubType(rawValue: $0) } ?? .miscellaneous,
                retailViewModel: retailViewModel
            )
        }
    }

    private var currentMonthCombinedTotal: Double {
        guard let summary = homeViewModel.summary else { return 0 }
        return (summary.rental?.totalAmount ?? 0) + summary.retail.totalAmount
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
        if !homeViewModel.summaryHasLoaded {
            Task {
                await homeViewModel.loadSummary()
            }
        }
        if !homeViewModel.recentInvoicesHaveLoaded {
            Task {
                await homeViewModel.loadRecentInvoices()
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
