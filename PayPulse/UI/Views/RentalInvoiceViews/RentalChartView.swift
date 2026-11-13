//
//  RentalChartView.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-02-20.
//

import SwiftUI

struct RentalChartView: View {
    @State private var selectedYear: Int? = nil
    @State private var selectedParam: ParameterType = .totalRent
    @ObservedObject var viewModel: RentalInvoicesViewModel

    init(viewModel: RentalInvoicesViewModel, initialYear: Int? = nil) {
        self.viewModel = viewModel
        _selectedYear = State(initialValue: initialYear)
    }
    
    var filteredData: [(String, Int)] {
        viewModel.getFilteredData(for: selectedParam, selectedYear: selectedYear)
    }
    var body: some View {
        VStack {
            ScreenHeader(title: "Rent charts", showsBackButton: true)

            if viewModel.invoicesHaveLoaded {
                HStack {
                    PickerButton(
                        title: "Parameter",
                        selectedValue: selectedParam,
                        options: ParameterType.allCases,
                        displayText: { $0.rawValue },
                        onSelectionChange: { selectedParam = $0 }
                    )
                    .frame(width: 140)
                    
                    Spacer()
                    
                    PickerButton(
                        title: "Year",
                        selectedValue: selectedYear,
                        options: [nil] + viewModel.invoices.keys.map { Int($0) }.sorted(),
                        displayText: { value in
                            value == nil ? "Quarterly" : String(value!)
                        },
                        onSelectionChange: { selectedYear = $0 }
                    )
                    .frame(width: 140)
                }
                .frame(width: UIScreen.main.bounds.width * 0.75)
                .padding()
                
                if filteredData.isEmpty {
                    Text("No data available for the selected year.")
                        .padding()
                } else {
                    RentalLineChart(data: filteredData)
                        .padding([.top, .horizontal])
                        .padding(.bottom, 30) // deliberate outlier, doesn't fit the xs..xxl ramp cleanly; left as a reserved literal rather than distorting the scale
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.primarySurface)
        .navigationBarBackButtonHidden()
        .hidesFloatingTabBar()
        // The back button lives in the header row, so the nav bar itself isn't needed
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    // ChartView(viewModel: RentalInvoicesViewModel())
}
