//
//  RentBreakdownVie.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2024-12-30.
//

import SwiftUI

struct RentBreakdownView: View {
    let breakdown: [(category: String, amount: Int)]
    
    var body: some View {
        InvoiceDetailsContainer {
            // Table header
            HeaderRow(key: "Category", value: "Amount")
            
            Divider()
            
            // Table rows
            ForEach(breakdown, id: \.category) { category, amount in
                let comparisonResult = category.compare("total", options: [.caseInsensitive])
                if comparisonResult != .orderedSame {
                    KeyValueRow(key: category, value: amount)
                }
            }
            
            Divider()
            
            // Total row            
            KeyValueRow(
                key: "Total",
                value: breakdown.last!.amount,
                makeValueBold: true
            )
        }
    }
}

#Preview {
    RentBreakdownView(
        breakdown: [
            ("baseRent", 9732),
            ("kallvatten", 125),
            ("varmvatten", 235),
            ("el", 241),
            ("moms", 600),
            ("total", 10000)
        ]
    )
}
