//
//  RectangleRoundedCorners.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-07-02.
//

import SwiftUI

struct RectangleRoundedCorners: View {
    var cornerRadius : CGFloat = Radius.sm
    var strokeWidth  : CGFloat = 1
    var color        : Color = Color.secondaryText
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .stroke(color, lineWidth: strokeWidth)
    }
}

#Preview {
    RectangleRoundedCorners()
}
