//
//  KeyValueRow.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2026-11-01.
//

import SwiftUI

struct KeyValueRow: View {
    let key: String
    let value: String
    var keyWidth: CGFloat? = nil
    var isHeader: Bool = false
    var makeValueBold: Bool = false
    var showCopyButton: Bool = false
    var copyButtonAction: (() -> Void)? = nil
    var keyOpacity: CGFloat = 1.0

    var body: some View {
        HStack(spacing: 5) {
            Group {
                if let keyWidth {
                    Text(key).frame(width: keyWidth, alignment: .leading)
                } else {
                    Text(key).frame(maxWidth: .infinity, alignment: .leading)
                }
            }
                .font(isHeader ? .tableHeader : .tableKey)
                .foregroundStyle(Color.secondaryDarkGray)
                .opacity(keyOpacity)

            if showCopyButton, let action = copyButtonAction {
                HStack(spacing: 5) {
                    valueView
                    CopyTextButton(action: action)
                }
            } else {
                valueView
            }
        }
    }

    @ViewBuilder
    private var valueView: some View {
        Group {
            if isHeader {
                Text(value)
                    .font(.tableHeader)
            } else if makeValueBold {
                Text(value)
                    .font(.tableValue)
                    .bold()
            } else {
                Text(value)
                    .font(.tableValue)
            }
        }
        .foregroundStyle(Color.secondaryDarkGray)
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

#Preview {
    VStack(spacing: 12) {
        KeyValueRow(key: "Category", value: "Amount", isHeader: true)
        KeyValueRow(key: "Vendor", value: "Wallenstam")
        KeyValueRow(key: "Total", value: "5 000 kr", makeValueBold: true)
        KeyValueRow(key: "OCR Reference", value: "123456789", showCopyButton: true, copyButtonAction: {})
        KeyValueRow(key: "Name:", value: "Azfar Imtiaz", keyWidth: 100)
    }
    .padding()
}
