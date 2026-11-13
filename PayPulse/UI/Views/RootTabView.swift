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
    @StateObject private var tabBarVisibility = FloatingTabBarVisibility()
    /// +1 when moving right in the tab order (Home → Rental → Retail), -1 when moving left
    @State private var direction: CGFloat = 1
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// How far content slides during a tab switch
    private let slideDistance: CGFloat = 36

    var body: some View {
        // A custom container rather than TabView: the system tab bar can't be reliably hidden
        // on pushed screens. Visited tabs stay alive (state + navigation preserved); unvisited
        // tabs aren't built until first selected, so their onAppear loads stay lazy.
        ZStack {
            ForEach(RootTab.allCases, id: \.self) { tab in
                if visitedTabs.contains(tab) {
                    tabContent(tab)
                        .opacity(selectedTab == tab ? 1 : 0)
                        .offset(x: restingOffset(for: tab))
                        .allowsHitTesting(selectedTab == tab)
                        .accessibilityHidden(selectedTab != tab)
                        // First visit: the tab is inserted in the same animated transaction as
                        // the selection change, so it slides in like an already-visited tab
                        .transition(
                            .asymmetric(
                                insertion: .opacity.combined(with: .offset(x: reduceMotion ? 0 : direction * slideDistance)),
                                removal: .opacity
                            )
                        )
                }
            }
        }
        // Overlay (not safeAreaInset): each tab's scroll view reserves the bar's height itself via
        // `.floatingTabBarScrollBehavior()`, which stays reliable through the nested NavigationStacks.
        .overlay(alignment: .bottom) {
            if tabBarVisibility.isVisible {
                FloatingTabBar(
                    items: tabItems,
                    selection: tabSelection,
                    isCollapsed: tabBarVisibility.isCollapsed,
                    onExpand: { tabBarVisibility.isCollapsed = false }
                )
                .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { height in
                    // Reserve space for the expanded bar only, so content doesn't jump on collapse
                    if !tabBarVisibility.isCollapsed {
                        tabBarVisibility.barHeight = height
                    }
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .environmentObject(tabBarVisibility)
        .onChange(of: selectedTab) {
            // A freshly shown tab starts with the full bar
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                tabBarVisibility.isCollapsed = false
            }
        }
    }

    /// Wraps the selection so direction and first-visit insertion change in the same transaction
    /// as the selection itself (the tab bar sets it inside `withAnimation`).
    private var tabSelection: Binding<RootTab> {
        Binding(
            get: { selectedTab },
            set: { newTab in
                guard newTab != selectedTab else { return }
                direction = index(of: newTab) > index(of: selectedTab) ? 1 : -1
                visitedTabs.insert(newTab)
                selectedTab = newTab
            }
        )
    }

    private func index(of tab: RootTab) -> Int {
        RootTab.allCases.firstIndex(of: tab) ?? 0
    }

    /// Hidden tabs rest just off to the side they sit on in the tab order, so selecting one
    /// slides it in from that side while the outgoing tab drifts the other way.
    private func restingOffset(for tab: RootTab) -> CGFloat {
        guard tab != selectedTab, !reduceMotion else { return 0 }
        return index(of: tab) < index(of: selectedTab) ? -slideDistance : slideDistance
    }

    private var tabItems: [FloatingTabItem] {
        [
            FloatingTabItem(tab: .home, title: "Home", systemImage: "square.grid.2x2", tint: .accentDeepOrange),
            FloatingTabItem(
                tab: .rental, title: "Rental", systemImage: "house", tint: .accentDeepOrange,
                count: rentalViewModel.invoicesHaveLoaded ? rentalViewModel.invoices.values.reduce(0) { $0 + $1.count } : nil
            ),
            FloatingTabItem(
                tab: .retail, title: "Retail", systemImage: "bag", tint: .accentDeepRed,
                count: retailViewModel.countsHaveLoaded ? retailViewModel.getTotalCount() : nil
            ),
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
            RetailLandingPage(invoiceService: invoiceService, viewModel: retailViewModel, summaryViewModel: homeViewModel)
        }
    }
}
