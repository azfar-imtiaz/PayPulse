//
//  HeaderRow.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-07-02.
//

import SwiftUI

struct HeaderRow: View {
    let key              : String
    let value            : String
    let textSize         : CGFloat = 16
    let fontName         : String = "Gotham-Medium"
    
    var body: some View {
        HStack(spacing: 5) {
            Text(key)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(value)
                .bold()
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .font(.custom(fontName, size: textSize))
        .foregroundStyle(Color.secondaryDarkGray)
    }
}

#Preview {
    HeaderRow(key: "Category", value: "Amount")
}
