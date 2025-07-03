//
//  KeyIntValueRow.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-07-02.
//

import SwiftUI

struct KeyIntValueRow: View {
    let key              : String
    let value            : Int
    var textSize         : CGFloat = 16
    var makeValueBold    : Bool = false
    var showCopyButton   : Bool = false
    var showCurrency     : Bool = false
    var copyButtonAction : (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: 5) {
            Text(key)
                .bold()
                .font(.custom("Gotham-Medium", size: textSize))
                .foregroundStyle(Color.secondaryDarkGray)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // add code to properly format the date
            if showCopyButton, let action = copyButtonAction {
                HStack(spacing: 5) {
                    displayIntValue(value: value, isBold: makeValueBold, showCurrency: showCurrency)
                    CopyTextButton(action: action)
                }
            } else {
                displayIntValue(value: value, isBold: makeValueBold, showCurrency: showCurrency)
            }
        }
    }
    
    @ViewBuilder
    func displayIntValue(value: Int, isBold: Bool = false, showCurrency: Bool = false) -> some View {
        let formattedValue = Utils.formatNumber(value)
        Group {
            switch isBold {
            case true:
                Group {
                    if showCurrency {
                        Text("\(formattedValue) SEK")
                    } else {
                        Text("\(formattedValue)")
                    }
                }
                .bold()
            default:
                if showCurrency {
                    Text("\(formattedValue) SEK")
                } else {
                    Text("\(formattedValue)")
                }
            }
        }
        .font(.custom("Gotham-Book", size: textSize))
        .foregroundStyle(.gray)
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

#Preview {
    KeyIntValueRow(key: "Header", value: 123)
}
