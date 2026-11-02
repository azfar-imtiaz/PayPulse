//
//  SoftCard.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2026-11-02.
//

import SwiftUI

struct SoftCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
        }
        .padding(Spacing.xl)
        .background(
            RoundedRectangle(cornerRadius: Radius.xl)
                .fill(Color.primaryOffWhite)
        )
        .shadow(color: Color.black.opacity(0.06), radius: 1, x: 0, y: 1)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 6)
    }
}

#Preview {
    SoftCard {
        Text("Template")
    }
    .padding()
    .background(Color.secondaryDarkGray.opacity(0.1))
}
