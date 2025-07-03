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
            HeaderRow(key: "Category", value: "Amount")
            
            Divider()
            
            // Table rows
            KeyIntValueRow(key: "Hyra", value: baseRent)
            KeyIntValueRow(key: "Kallvatten", value: kallvatten)
            KeyIntValueRow(key: "Varmvatten", value: varmvatten)
            KeyIntValueRow(key: "El", value: electricity)
            KeyIntValueRow(key: "Moms", value: moms)
            
            Divider()
            
            // Total row            
            KeyIntValueRow(key: "Total", value: totalAmount, makeValueBold: true)
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
