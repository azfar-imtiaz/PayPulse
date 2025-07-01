//
//  InvoicesListView.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-01-26.
//

import SwiftUI

struct RentalInvoicesListView: View {
    @ObservedObject var viewModel: InvoicesViewModel
    @State private var expandedYears: Set<Int> = []
    
    var body: some View {
        List {
            ScrollView {
                
                Section(header: getSectionHeader(text: "Latest invoice")) {
                    if let latestInvoice = viewModel.latestInvoice, latestInvoice.isDueInCurrentMonth() {
                        NavigationLink {
                            InvoiceDetailsView(invoice: latestInvoice)
                        } label: {
                            invoiceListItemView(invoice: latestInvoice, isLastInvoice: false)
                        }
                    } else {
                        noInvoiceListItemView()
                    }
                }
                
                // display all older invoices
                ForEach(Array(viewModel.invoices.keys), id: \.self ) { year in
                    let yearString = String(year)
                    Section(header:
                        HStack {
                            getSectionHeader(text: yearString)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .rotationEffect(.degrees(expandedYears.contains(year) ? 180 : 0))
                                .foregroundStyle(Color.accentDeepOrange)
                        }
                        .onTapGesture {
                            withAnimation(.snappy(duration: 0.2)) {
                                if expandedYears.contains(year) {
                                    expandedYears.remove(year)
                                } else {
                                    expandedYears.insert(year)
                                }
                            }
                        }
                    ) {
                        if expandedYears.contains(year) {
                            let lastInvoiceID = viewModel.invoices[year]?.last?.invoiceID ?? ""
                            if let invoicesForYear = viewModel.invoices[year] {
                                ForEach(invoicesForYear) { invoice in
                                    NavigationLink {
                                        InvoiceDetailsView(invoice: invoice)
                                    } label: {
                                        invoiceListItemView(invoice: invoice, isLastInvoice: invoice.invoiceID == lastInvoiceID)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.primaryOffWhite)
        }
        .listStyle(.inset)
        .background(Color.primaryOffWhite)
        .scrollContentBackground(.hidden)
        .navigationTitle("Rental Invoices")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func invoiceListItemView(invoice: InvoiceModel, isLastInvoice: Bool) -> some View {
        VStack(alignment: .leading) {
            Text("\(invoice.getDueMonthName()), \(invoice.dueDateYear)")
                .font(.custom("Gotham-Medium", size: 20))
                .foregroundStyle(Color.secondaryDarkGray)
                .padding(.vertical, 5)
            
            HStack(spacing: 0) {
                Text("Due Date: ")
                    .foregroundStyle(Color.secondaryDarkGray)
                    .font(.custom("Gotham-Book", size: 16))
                
                Text("\(invoice.dueDate)")
                    .foregroundStyle(.gray)
                    .font(.custom("Gotham-Light", size: 16))
            }
            
            
            HStack(spacing: 0) {
                Text("Total Rent: ")
                    .foregroundStyle(Color.secondaryDarkGray)
                    .font(.custom("Gotham-Book", size: 16))
                
                Text("\(Utils.formatNumber(invoice.totalAmount)) kr")
                    .foregroundStyle(.gray)
                    .font(.custom("Gotham-Light", size: 16))
            }
            
            Divider()
                .opacity(isLastInvoice ? 0 : 1)
        }
    }
    
    func noInvoiceListItemView() -> some View {
        VStack(alignment: .leading) {
            Text("\(viewModel.getCurrentMonthNameAndYear())")
                .font(.custom("Gotham-Medium", size: 20))
                .foregroundStyle(Color.secondaryDarkGray)
                .padding(.vertical, 5)
            
            Text("Not available yet.")
                .font(.custom("Gotham-BookItalic", size: 16))
                .foregroundStyle(.gray)
            
            Divider()
                .opacity(0)
        }
    }
    
    func getSectionHeader(text: String) -> some View {
        HStack {
            Text("\(text)")
                .font(.custom("Gotham-Black", size: 18))
                .foregroundStyle(Color.accentDeepOrange)
            
            Spacer()
        }
        .padding(.vertical, 10)
    }
}

#Preview {
    RentalInvoicesListView(
        viewModel: InvoicesViewModel(
            invoiceService: InvoiceService(
                apiClient: PayPulseAPIClient(
                    authManager: AuthManager.shared
                )
            )
        )
    )
}
