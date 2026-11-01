//
//  RentBreakdownVie.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2024-12-30.
//

import SwiftUI

struct RentBreakdownView: View {
    let baseRent: Int
    let kallvatten: Int
    let varmvatten: Int
    let electricity: Int
    let moms: Int
    let totalAmount: Int
    
    var body: some View {
        InvoiceDetailsContainer {
            // Table header
            KeyValueRow(key: "Category", value: "Amount", isHeader: true)

            Divider()

            // Table rows
            KeyValueRow(key: "Hyra", value: Utils.formatNumber(baseRent))
            KeyValueRow(key: "Kallvatten", value: Utils.formatNumber(kallvatten))
            KeyValueRow(key: "Varmvatten", value: Utils.formatNumber(varmvatten))
            KeyValueRow(key: "El", value: Utils.formatNumber(electricity))
            KeyValueRow(key: "Moms", value: Utils.formatNumber(moms))

            Divider()

            // Total row
            KeyValueRow(key: "Total", value: Utils.formatNumber(totalAmount), makeValueBold: true)
        }
    }
}

#Preview {
    RentBreakdownView(
        baseRent: 9732,
        kallvatten: 125,
        varmvatten: 235,
        electricity: 241,
        moms: 600,
        totalAmount: 10000
    )
}
