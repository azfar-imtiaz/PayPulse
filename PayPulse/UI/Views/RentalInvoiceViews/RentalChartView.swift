//
//  ChartView.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-02-20.
//

import SwiftUI

struct RentalChartView: View {
    @State private var selectedYear: Int? = nil
    @State private var selectedParam: ParameterType = .totalRent
    @ObservedObject var viewModel: InvoicesViewModel
    
    var filteredData: [(String, Int)] {
        viewModel.getFilteredData(for: selectedParam, selectedYear: selectedYear)
    }
    var body: some View {
        VStack {
            if viewModel.invoicesHaveLoaded {
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
                        ForEach(viewModel.invoices.keys.map { Int($0) }, id: \.self) { year in
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
                    RentalLineChart(data: filteredData)
                        .padding([.top, .horizontal])
                        .padding(.bottom, 30)
                }
            }
        }
    }
}

#Preview {
    // ChartView(viewModel: InvoicesViewModel())
}
