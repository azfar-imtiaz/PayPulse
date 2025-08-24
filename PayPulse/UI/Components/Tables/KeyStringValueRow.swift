//
//  KeyStringValueRow.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-07-03.
//

import SwiftUI

struct KeyStringValueRow: View {
    let key              : String
    let value            : String
    var textSize         : CGFloat = 16
    var makeValueBold    : Bool = false
    var showCopyButton   : Bool = false
    var copyButtonAction : (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: 5) {
            Text(key)
                .bold()
                .font(.custom("Montserrat-Medium", size: textSize))
                .foregroundStyle(Color.secondaryDarkGray)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // add code to properly format the date
            if showCopyButton, let action = copyButtonAction {
                HStack(spacing: 5) {
                    displayStringValue(value: value, isBold: makeValueBold)
                    CopyTextButton(action: action)
                }
            } else {
                displayStringValue(value: value, isBold: makeValueBold)
            }
        }
    }
    
    @ViewBuilder
    func displayStringValue(value: String, isBold: Bool = false) -> some View {
        Group {
            if isBold {
                Text(value).bold()
            } else  {
                Text(value)
            }
        }
        .font(.custom("Montserrat-Regular", size: textSize))
        .foregroundStyle(.gray)
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

#Preview {
    KeyStringValueRow(key: "Header", value: "Value")
}
