//
//  RectangleRoundedCorners.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-07-02.
//

import SwiftUI

struct RectangleRoundedCorners: View {
    var cornerRadius : CGFloat = 8
    var strokeWidth  : CGFloat = 1
    var color        : Color = Color.secondaryDarkGray
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .stroke(color, lineWidth: strokeWidth)
    }
}

#Preview {
    RectangleRoundedCorners()
}
