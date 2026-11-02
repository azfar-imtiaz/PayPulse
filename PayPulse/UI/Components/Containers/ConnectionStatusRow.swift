//
//  ConnectionStatusRow.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2026-11-02.
//

import SwiftUI

struct ConnectionStatusRow: View {
    let markText: String
    let markColor: Color
    let name: String
    let isConnected: Bool

    var body: some View {
        HStack {
            HStack(spacing: Spacing.md) {
                RoundedRectangle(cornerRadius: Radius.sm)
                    .fill(markColor)
                    .frame(width: 26, height: 26)
                    .overlay(
                        Text(markText)
                            .font(.footnote)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.white)
                    )

                Text(name)
                    .font(.tableValue)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.secondaryDarkGray)
            }

            Spacer()

            HStack(spacing: 5) {
                Circle()
                    .fill(isConnected ? Color.green : Color.secondaryDarkGray.opacity(0.4))
                    .frame(width: 5, height: 5)
                Text(isConnected ? "Connected" : "Not connected")
                    .font(.footnote)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(isConnected ? Color.green : Color.secondaryDarkGray)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xs)
            .background(
                Capsule()
                    .fill((isConnected ? Color.green : Color.secondaryDarkGray).opacity(0.12))
            )
        }
        .padding(.vertical, Spacing.md)
    }
}

#Preview {
    VStack(spacing: 0) {
        ConnectionStatusRow(markText: "G", markColor: Color(red: 0.78, green: 0.31, blue: 0.23), name: "Gmail", isConnected: true)
        Divider()
        ConnectionStatusRow(markText: "O", markColor: Color(red: 0.18, green: 0.44, blue: 0.69), name: "Outlook", isConnected: false)
    }
    .padding()
}
