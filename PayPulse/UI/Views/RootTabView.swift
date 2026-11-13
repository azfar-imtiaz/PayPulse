//
//  RootTabView.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2026-11-13.
//

import SwiftUI

enum RootTab: Hashable, CaseIterable {
    case home
    case rental
    case retail
}

/// Authenticated root: Home / Rental / Retail tabs, each owning its own NavigationStack.
/// Owns the shared view models so tabs and Home's recent-row destinations use the same state.
struct RootTabView: View {
    let invoiceService : InvoiceService
    let userService    : UserService
    let gmailService   : GmailAuthService
    let outlookService : OutlookAuthService

    @StateObject private var rentalViewModel : RentalInvoicesViewModel
    @StateObject private var retailViewModel : RetailInvoicesViewModel
    @StateObject private var homeViewModel   : HomeViewModel
    @State private var selectedTab: RootTab = .home

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
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "square.grid.2x2", value: RootTab.home) {
                ContentView(
                    invoiceService: invoiceService,
                    userService: userService,
                    gmailService: gmailService,
                    outlookService: outlookService,
                    rentalViewModel: rentalViewModel,
                    retailViewModel: retailViewModel,
                    homeViewModel: homeViewModel
                )
            }

            Tab("Rental", systemImage: "house", value: RootTab.rental) {
                RentalLandingPage(invoiceService: invoiceService, viewModel: rentalViewModel)
            }

            Tab("Retail", systemImage: "bag", value: RootTab.retail) {
                RetailLandingPage(invoiceService: invoiceService, viewModel: retailViewModel)
            }
        }
        .tint(Color.accentDeepOrange)
        .sensoryFeedback(.selection, trigger: selectedTab)
    }
}
