//
//  ErrorRow.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2026-11-12.
//

import SwiftUI

struct ErrorRow: View {
    let context: String

    var body: some View {
        Text("Error: Could not display \(context)")
            .font(.bodyStandard)
            .foregroundStyle(Color.accentDeepRed)
    }
}
