//
//  HeaderYearSelectionButton.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-07-03.
//

import SwiftUI

struct HeaderYearSelectionButton: View {
    @Binding var selectedYear: Int
    let year: Int
    let scrollFunction: () -> Void
    
    var body: some View {
        Button {
            scrollFunction()
        } label: {
            Text(String(year))
                .id(year)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .font(.tableHeader)
                .foregroundStyle(
                    year == selectedYear ? Color.secondaryDarkGray : Color.primaryOffWhite
                )
                .background(
                    Capsule()
                        .fill(year == selectedYear ? Color.primaryOffWhite : .clear)
                )
        }
    }
}

#Preview {
    HStack(spacing: 15) {
        HeaderYearSelectionButton(
            selectedYear: .constant(2022),
            year: 2021,
            scrollFunction: {}
        )
        
        HeaderYearSelectionButton(
            selectedYear: .constant(2024),
            year: 2024,
            scrollFunction: {}
        )
    }
}
