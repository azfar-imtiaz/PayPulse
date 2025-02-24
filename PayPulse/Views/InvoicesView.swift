//
//  InvoicesView.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-01-04.
//

import SwiftUI

struct InvoicesView: View {
    @StateObject var viewModel = InvoiceViewModel()
    @State private var expandedYears: Set<Int> = []
    
    var body: some View {
        NavigationStack {
            TabView {
                InvoicesListView()
                    .tabItem {
                        Label("Invoices", systemImage: "list.bullet.rectangle.portrait.fill")
                    }
                
                ChartView(viewModel: viewModel)
                    .background(Color.primaryOffWhite)
                    .tabItem {
                        Label("Charts", systemImage: "chart.xyaxis.line")
                    }
            }
            .onAppear {
                viewModel.fetchInvoices()
            }
        }
    }
    
    
}

#Preview {
    InvoicesView()
}
