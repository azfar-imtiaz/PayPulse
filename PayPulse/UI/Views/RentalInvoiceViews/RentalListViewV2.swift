//
//  RentalListViewV2.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-07-02.
//

import SwiftUI

struct RentalListViewV2: View {
    @ObservedObject var viewModel: InvoicesViewModel
    @State var selectedYear: Int
    
    var body: some View {
        VStack {
            yearsHeader(years: Array(viewModel.invoices.keys))
            // yearsHeader(years: [2025, 2024, 2023, 2022, 2021, 2020, 2019])
                .padding(.horizontal)
                .padding(.bottom, 20)
            
            invoicesContainer()
        }
        .background(Color.secondaryDarkGray)
    }
    
    func invoicesContainer() -> some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 40)
                .fill(Color.white)
                .ignoresSafeArea(edges: .bottom)
            
            VStack {
                ScrollView(.vertical, showsIndicators: false) {
                    if let invoices = viewModel.invoices[selectedYear] {
                        ForEach(invoices) { invoice in
                            InvoiceSummaryWithDate(
                                invoice: invoice,
                                vendor: "Wallenstam"
                            )
                            .padding([.horizontal, .top])
                        }
                    }
                }
            }
            .padding(.top)
        }
    }
    
    func yearsHeader(years: [Int]) -> some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(years, id: \.self) { year in
                        
                        Text(String(year))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .font(.custom("Montserrat-Bold", size: 16))
                            .foregroundStyle(year == selectedYear ? Color.secondaryDarkGray : .white)
                            .background(
                                Capsule()
                                    .fill(year == selectedYear ? .white : .clear)
                            )
                            .id(year)
                            .onTapGesture {
                                withAnimation {
                                    selectedYear = year
                                    scrollItemToCenter(selectedYear: year, years: years, in: proxy)
                                }
                            }
                    }
                }
                .scrollTargetLayout()
            }
            .padding(.horizontal, 12)
            .scrollTargetBehavior(.viewAligned)
        }
    }
    
    private func scrollItemToCenter(selectedYear: Int, years: [Int], in proxy: ScrollViewProxy) {
        guard let index = years.firstIndex(of: selectedYear) else {
            return
        }
        
        if index > 1 && index < years.count - 1 {
            proxy.scrollTo(selectedYear, anchor: .center)
        } else {
            proxy.scrollTo(selectedYear, anchor: index < 1 ? .leading : .trailing)
        }
    }
}

#Preview {
    RentalListViewV2(
        viewModel: InvoicesViewModel(
            invoiceService: InvoiceService(
                apiClient: PayPulseAPIClient(
                    authManager: AuthManager.shared
                )
            )
        ),
        selectedYear: 2025
    )
}
