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

struct InvoicesView: View {
    @StateObject var viewModel = InvoiceViewModel()
    @State private var expandedYears: Set<Int> = []
    @State private var selectedTab: TabTitles = .invoices
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                InvoicesListView()
                    .tabItem {
                        Label("Invoices", systemImage: "list.bullet.rectangle.portrait.fill")
                    }
                    .tag(TabTitles.invoices)
                
                ChartView(viewModel: viewModel)
                    .background(Color.primaryOffWhite)
                    .tabItem {
                        Label("Charts", systemImage: "chart.xyaxis.line")
                    }
                    .tag(TabTitles.graphs)
            }
            .onAppear {
                viewModel.fetchInvoices()
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
    InvoicesView()
}
