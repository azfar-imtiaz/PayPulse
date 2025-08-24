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
                    CustomPickerButton(
                        title: "Parameter",
                        selectedValue: selectedParam,
                        options: ParameterType.allCases,
                        displayText: { $0.rawValue },
                        onSelectionChange: { selectedParam = $0 }
                    )
                    .frame(width: 140)
                    
                    Spacer()
                    
                    CustomPickerButton(
                        title: "Year",
                        selectedValue: selectedYear,
                        options: [nil] + viewModel.invoices.keys.map { Int($0) }.sorted(),
                        displayText: { value in
                            value == nil ? "Quarterly" : String(value!)
                        },
                        onSelectionChange: { selectedYear = $0 }
                    )
                    .frame(width: 120)
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
