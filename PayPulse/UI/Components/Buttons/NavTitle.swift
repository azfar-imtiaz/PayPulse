//
//  NavTitle.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2026-11-01.
//

import SwiftUI

struct NavTitle: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.navigationStandard)
            .foregroundStyle(Color.secondaryText)
    }
}

#Preview {
    NavTitle(text: "Profile")
}
