//
//  SectionTitle.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2026-11-12.
//

import SwiftUI

struct SectionTitle: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.bodyLarge)
            .bold()
            .foregroundStyle(Color.secondaryText)
    }
}
