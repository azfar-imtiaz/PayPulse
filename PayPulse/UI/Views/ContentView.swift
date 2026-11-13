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

    @ObservedObject var rentalViewModel : RentalInvoicesViewModel
    @ObservedObject var retailViewModel : RetailInvoicesViewModel
    @ObservedObject var homeViewModel   : HomeViewModel
    @Namespace private var recentActivityNamespace
    @AppStorage("home.graph.includeRent") private var graphIncludesRent = false
    @AppStorage("home.graph.compareLastMonth") private var graphComparesLastMonth = true

    @EnvironmentObject var authManager: AuthManager
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.presentToast) var presentToast

    private var homeDataHasLoaded: Bool {
        rentalViewModel.invoicesHaveLoaded
            && retailViewModel.countsHaveLoaded
            && homeViewModel.summaryHasLoaded
            && homeViewModel.recentInvoicesHaveLoaded
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .center) {
                VStack(spacing: 0) {

                    ScreenHeader(title: "PayPulse", subtitle: "All your invoices, one place.") {
                        NavigationLink {
                            ProfileView(userService: userService, gmailService: gmailService, outlookService: outlookService)
                        } label: {
                            Utils.getIconColored(colorScheme: colorScheme, iconName: "user")
                        }
                        .accessibilityLabel("Profile")
                    }

                ScrollView {
                    VStack(spacing: 12) {
                        summaryCard

                        if !homeViewModel.recentInvoices.isEmpty {
                            recentActivitySection
                                .padding(.top, Spacing.md)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, Spacing.xl)
                }
                .floatingTabBarScrollBehavior()
                }
                .background(Color.primarySurface)
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

                LoadingDotsView(
                    isLoading: Binding(get: { !homeDataHasLoaded }, set: { _ in }),
                    loadingText: "Loading your invoices..."
                )
            }
        }
    }

    private var summaryCard: some View {
        let now = homeViewModel.referenceDate
        return SpendingGraphCard(
            isLoaded: homeViewModel.summaryHasLoaded,
            total: homeViewModel.total(includeRent: graphIncludesRent),
            current: homeViewModel.currentSeries(includeRent: graphIncludesRent, now: now),
            previous: homeViewModel.previousSeries(includeRent: graphIncludesRent),
            todayProgress: homeViewModel.period.progress(for: now),
            today: now,
            hasRent: homeViewModel.hasRent,
            hasPrevious: homeViewModel.hasPreviousMonth,
            includeRent: $graphIncludesRent,
            compareLastMonth: $graphComparesLastMonth
        )
    }

    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text("Recent invoices")
                .font(.headingSmall)
                .fontWeight(.semibold)
                .foregroundStyle(Color.secondaryText)
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
                        trailingIndicator: .dot(dotColor(for: item)),
                        transitionID: "home_recent_\(item.invoiceID)",
                        namespace: recentActivityNamespace
                    ) {
                        recentItemDestination(for: item)
                    }
                }
            }
        }
    }

    private func dotColor(for item: InvoiceSummaryItem) -> Color {
        switch item.invoiceType {
        case .rental:
            return .accentDeepOrange
        case .retail:
            return item.subType.flatMap { RetailInvoiceSubType(rawValue: $0) }?.color ?? RetailInvoiceSubType.miscellaneous.color
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
