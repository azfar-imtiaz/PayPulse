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
            
            // List(viewModel.invoices) { invoice in
            List {
                ScrollView {
                    
                    Section(header: getSectionHeader(text: "Latest invoice")) {
                        if let latestInvoice = viewModel.latestInvoice, latestInvoice.isCurrentMonthInvoice() {
                            NavigationLink {
                                InvoiceView(invoice: latestInvoice)
                            } label: {
                                invoiceListItemView(invoice: latestInvoice, isLastInvoice: false)
                            }
                        } else {
                            noInvoiceListItemView()
                        }
                    }
                    
                    // display all older invoices
                    let invoicesSortedByYear = viewModel.getInvoicesByYearSorted()
                    ForEach(invoicesSortedByYear, id: \.self) { year in
                        Section(header:
                            HStack {
                                getSectionHeader(text: "\(year)")
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
                                let lastInvoiceId = viewModel.invoicesByYear[year]!.last?.id
                                ForEach(viewModel.invoicesByYear[year]!) { invoice in
                                    NavigationLink {
                                        InvoiceView(invoice: invoice)
                                    } label: {
                                        invoiceListItemView(invoice: invoice, isLastInvoice: invoice.id == lastInvoiceId)
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
            .onAppear {
                viewModel.fetchInvoices()
            }
        }
    }
    
    func invoiceListItemView(invoice: Invoice, isLastInvoice: Bool) -> some View {
        VStack(alignment: .leading) {
            Text("\(invoice.dueDateMonthYear)")
                .font(.custom("Gotham-Medium", size: 20))
                .foregroundStyle(Color.secondaryDarkGray)
                .padding(.vertical, 5)
            
            HStack(spacing: 0) {
                Text("Due Date: ")
                    .foregroundStyle(Color.secondaryDarkGray)
                    .font(.custom("Gotham-Book", size: 16))
                
                Text(invoice.dueDate)
                    .foregroundStyle(.gray)
                    .font(.custom("Gotham-Light", size: 16))
            }
            
            
            HStack(spacing: 0) {
                Text("Total Rent: ")
                    .foregroundStyle(Color.secondaryDarkGray)
                    .font(.custom("Gotham-Book", size: 16))
                
                Text("\(Invoice.getAmountFormatted(amount: invoice.totalAmount)) kr")
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
//            RoundedRectangle(cornerRadius: 8)
//                .stroke(Color.secondaryDarkGray, lineWidth: 1)
//                .frame(width: 150, height: 30)
//                .overlay {
//                    Text(text)
//                        .font(.custom("Gotham-Medium", size: 18))
//                        .foregroundStyle(Color.accentDeepOrange)
//                }
                
            
            Text(text)
                .font(.custom("Gotham-Black", size: 18))
                .foregroundStyle(Color.accentDeepOrange)
            
            Spacer()
        }
        .padding(.vertical, 10)
    }
}

#Preview {
    InvoicesView()
}
