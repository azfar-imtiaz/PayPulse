//
//  Headeryears.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-07-03.
//

import SwiftUI

struct HeaderYears: View {
    let years: [Int]
    @Binding var selectedYear: Int
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(years, id: \.self) { year in
                        
                        HeaderYearSelectionButton(selectedYear: $selectedYear, year: year) {
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
    HeaderYears(
        years: [2025, 2024, 2023, 2022],
        selectedYear: .constant(2022)
    )
}
