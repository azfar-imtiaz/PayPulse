//
//  ChartView.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-02-20.
//

import SwiftUI

struct ChartView: View {
    @State private var selectedYear: Int? = nil
    @State private var selectedParam: ParameterType = .totalRent
    @ObservedObject var viewModel: InvoiceViewModel
    
    var filteredData: [(String, Int)] {
        viewModel.getFilteredData(for: selectedParam, year: selectedYear, from: viewModel.invoices).reversed()
    }
    var body: some View {
        VStack {
            
            HStack {
                Picker("Parameter", selection: $selectedParam) {
                    ForEach(ParameterType.allCases, id: \.self) { param in
                        Text(param.rawValue).tag(param)
                    }
                }
                .pickerStyle(.menu)
                
                Spacer()
                
                Picker("Select year", selection: $selectedYear) {
                    Text("All years").tag(nil as Int?)
                    ForEach(Set(viewModel.invoices.map { $0.getInvoiceDueYear() }).sorted(), id: \.self) { year in
                        Text(String(year)).tag(year as Int?)
                    }
                }
                .pickerStyle(.menu)
            }
            .frame(width: UIScreen.main.bounds.width * 0.7)
            .padding()
            
            if filteredData.isEmpty {
                Text("No data available for the selected year.")
                    .padding()
            } else {
                LineChartView(data: filteredData)
                    .padding([.top, .horizontal])
                    .padding(.bottom, 30)
            }
            
        }
    }
}

#Preview {
    ChartView(viewModel: InvoiceViewModel())
}
