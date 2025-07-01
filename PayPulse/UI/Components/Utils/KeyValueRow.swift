//
//  KeyValueRow.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-07-02.
//

import SwiftUI

struct KeyValueRow: View {
    let key              : String
    let value            : Any
    var textSize         : CGFloat = 16
    var makeValueBold    : Bool = false
    var showCopyButton   : Bool = false
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
                    displayValue(value: value, isBold: makeValueBold)
                    CopyTextButton(action: action)
                }
            } else {
                displayValue(value: value, isBold: makeValueBold)
            }
        }
    }
    
    func displayValue(value: Any, isBold: Bool = false) -> some View {
        Group {
            if let stringValue = value as? String {
                isBold ? Text(stringValue).bold() : Text(stringValue)
            } else if let intValue = value as? Int {
                let formattedValue = Utils.formatNumber(intValue)
                isBold ? Text(formattedValue).bold() : Text(formattedValue)
            }
        }
        .font(.custom("Gotham-Book", size: textSize))
        .foregroundStyle(.gray)
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

#Preview {
    KeyValueRow(key: "Header", value: "Value")
}
