//
//  InvoiceSummary.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-07-03.
//

import SwiftUI

struct InvoiceSummary: View {
    let vendor: String
    let dueDate: String
    let totalAmount: Int
    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                Text(vendor)
                    .font(.buttonStandard)
                    .foregroundStyle(Color.secondaryDarkGray)
                Spacer()
                let hasDueDatePassed = Utils.hasDueDateExpired(dueDate)
                Circle()
                    .fill(hasDueDatePassed ? .green : .accentDeepOrange)
                    .frame(width: 8, height: 8)
            }
            
            HStack {
                Text("\(Utils.formatNumber(totalAmount)) SEK")
                Spacer()
                Text(dueDate)
            }
            .font(.bodyStandard)
            .foregroundStyle(.gray)
        }
    }
}

#Preview {
    InvoiceSummary(
        vendor: "Wallenstam",
        dueDate: "12-11-2021",
        totalAmount: 5000
    )
}
