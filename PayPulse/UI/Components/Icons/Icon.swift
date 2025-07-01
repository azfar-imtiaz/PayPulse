//
//  Icon.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-07-02.
//

import SwiftUI

struct Icon: View {
    let name     : String
    var size     : CGFloat = 20
    var color    : Color = Color.accentDeepOrange
    
    var body: some View {
        Image(name)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
    }
}

#Preview {
    Icon(name: "copy-icon")
}
