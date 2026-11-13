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

    @State private var visitedTabs: Set<RootTab> = [.home]

    var body: some View {
        // A custom container rather than TabView: the system tab bar can't be reliably hidden
        // on pushed screens. Visited tabs stay alive (state + navigation preserved); unvisited
        // tabs aren't built until first selected, so their onAppear loads stay lazy.
        ZStack {
            ForEach(RootTab.allCases, id: \.self) { tab in
                if visitedTabs.contains(tab) {
                    tabContent(tab)
                        .opacity(selectedTab == tab ? 1 : 0)
                        .allowsHitTesting(selectedTab == tab)
                        .accessibilityHidden(selectedTab != tab)
                }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            FloatingTabBar(items: tabItems, selection: $selectedTab)
        }
        .onChange(of: selectedTab) { _, newTab in
            visitedTabs.insert(newTab)
        }
    }

    private var tabItems: [FloatingTabItem] {
        [
            FloatingTabItem(tab: .home, title: "Home", systemImage: "square.grid.2x2", tint: .accentDeepOrange),
            FloatingTabItem(tab: .rental, title: "Rental", systemImage: "house", tint: .accentDeepOrange),
            FloatingTabItem(tab: .retail, title: "Retail", systemImage: "bag", tint: .accentDeepRed),
        ]
    }

    @ViewBuilder
    private func tabContent(_ tab: RootTab) -> some View {
        switch tab {
        case .home:
            ContentView(
                invoiceService: invoiceService,
                userService: userService,
                gmailService: gmailService,
                outlookService: outlookService,
                rentalViewModel: rentalViewModel,
                retailViewModel: retailViewModel,
                homeViewModel: homeViewModel
            )
        case .rental:
            RentalLandingPage(invoiceService: invoiceService, viewModel: rentalViewModel)
        case .retail:
            RetailLandingPage(invoiceService: invoiceService, viewModel: retailViewModel)
        }
    }
}
