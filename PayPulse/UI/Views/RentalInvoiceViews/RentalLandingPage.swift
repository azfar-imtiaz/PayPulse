//
//  InvoicesView.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-01-04.
//

import SwiftUI

enum TabTitles: String {
    case invoices
    case graphs
}

struct RentalLandingPage: View {
    let invoiceService: InvoiceService
    @StateObject var viewModel: InvoicesViewModel
    
    @State private var expandedYears: Set<Int> = []
    @State private var selectedTab: TabTitles = .invoices
    @Environment(\.dismiss) private var dismiss
    
    init(invoiceService: InvoiceService) {
        _viewModel = StateObject(wrappedValue: InvoicesViewModel(invoiceService: invoiceService))
        self.invoiceService = invoiceService
    }
    
    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                RentalListView(viewModel: viewModel)
                    .tabItem {
                        Label("Invoices", systemImage: "list.bullet.rectangle.portrait.fill")
                    }
                    .tag(TabTitles.invoices)
                
                RentalChartView(viewModel: viewModel)
                    .background(Color.primaryOffWhite)
                    .tabItem {
                        Label("Charts", systemImage: "chart.xyaxis.line")
                    }
                    .tag(TabTitles.graphs)
            }
            .onAppear {
                Task {
                    await viewModel.getInvoices()
                }
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left.circle")
                }
            }
        }
        .navigationTitle(selectedTab.rawValue.capitalized)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    
}

#Preview {
    RentalLandingPage(invoiceService: InvoiceService(apiClient: PayPulseAPIClient(authManager: AuthManager.shared)))
}
