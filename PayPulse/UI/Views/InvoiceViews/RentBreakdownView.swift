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
        VStack(alignment: .leading, spacing: 16) {
            // Table header
            HStack {
                Text("Category")
                    .font(.custom("Gotham-Medium", size: 16))
                    .foregroundStyle(Color.secondaryDarkGray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("Amount")
                    .font(.custom("Gotham-Medium", size: 16))
                    .foregroundStyle(Color.secondaryDarkGray)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            
            Divider()
            
            // Table rows
            
            ForEach(breakdown, id: \.category) { category, amount in
                
                let comparisonResult = category.compare("total", options: [.caseInsensitive])
                
                if comparisonResult != .orderedSame {
                    HStack {
                        Text(category)
                            .font(.custom("Gotham-Medium", size: 16))
                            .foregroundStyle(Color.secondaryDarkGray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(Utils.formatNumber(amount))
                            .font(.custom("Gotham-Book", size: 16))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .foregroundStyle(.gray)
                    }
                }
            }
            
            Divider()
            
            // Total row
            
            HStack {
                Text("Total")
                    .bold()
                    .foregroundStyle(Color.secondaryDarkGray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(Utils.formatNumber(breakdown.last!.amount))
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .foregroundStyle(.gray)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.secondaryDarkGray, lineWidth: 1)
        )
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
