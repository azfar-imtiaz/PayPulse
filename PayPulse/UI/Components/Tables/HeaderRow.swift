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
    let fontName         : String = "Montserrat-Bold"
    
    var body: some View {
        HStack(spacing: 5) {
            Text(key)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(value)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .font(.custom(fontName, size: textSize))
        .foregroundStyle(Color.secondaryDarkGray)
    }
}

#Preview {
    HeaderRow(key: "Category", value: "Amount")
}
