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
    let currency: String
    let circleColor: Color?

    init(vendor: String, dueDate: String, totalAmount: Int, currency: String = "SEK", circleColor: Color? = nil) {
        self.vendor = vendor
        self.dueDate = dueDate
        self.totalAmount = totalAmount
        self.currency = currency
        self.circleColor = circleColor
    }

    var body: some View {
        VStack {
            HStack(alignment: .top) {
                Text(vendor)
                    .font(.buttonStandard)
                    .foregroundStyle(Color.secondaryDarkGray)
                Spacer()

                if circleColor == nil {
                    let hasPassed = Utils.hasDueDateExpired(dueDate)
                    Text(hasPassed ? "PAID" : "DUE")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(hasPassed ? Color.green : Color.accentDeepOrange))
                } else {
                    Circle()
                        .fill(getCircleColor())
                        .frame(width: 8, height: 8)
                }
            }

            HStack {
                Text(" \(currency) \(Utils.formatNumber(totalAmount))")
                Spacer()
                Text(dueDate)
            }
            .font(.bodyStandard)
            .foregroundStyle(.gray)
        }
    }

    private func getCircleColor() -> Color {
        if let fixedColor = circleColor {
            return fixedColor
        }

        // Default behavior for rental invoices: green if due date passed, orange if not
        let hasDueDatePassed = Utils.hasDueDateExpired(dueDate)
        return hasDueDatePassed ? .green : .accentDeepOrange
    }
}

#Preview {
    InvoiceSummary(
        vendor: "Wallenstam",
        dueDate: "12-11-2021",
        totalAmount: 5000
    )
}
