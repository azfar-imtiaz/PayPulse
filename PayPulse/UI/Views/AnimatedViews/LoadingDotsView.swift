//
//  LoadingDotsView.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-07-07.
//

import SwiftUI

struct LoadingDotsView: View {
    @Binding var isLoading          : Bool
    @State private var dotScales    : [CGFloat] = [1.0, 1.0, 1.0]
    @State private var currentIndex : Int = 0
    
    var loadingText : String = "Loading..."
    let dotColors   : [Color] = [Color.primaryOffWhite, Color.secondaryDarkGray, Color.accentDeepOrange]
    
    var body: some View {
        ZStack {
            if isLoading {
                Color.black.opacity(0.6)
                    .ignoresSafeArea(edges: .all)
                
                VStack {
                    HStack(spacing: 8) {
                        ForEach(0..<3) { index in
                            Circle()
                                .fill(dotColors[index])
                                .frame(width: 12, height: 12)
                                .scaleEffect(dotScales[index])
                                // dim when not active
                                .opacity(dotScales[index] == 1.0 ? 1.0 : 0.6)
                        }
                    }
                    .onAppear {
                        startPulsingAnimation()
                    }
                    .onDisappear {
                        dotScales = [1.0, 1.0, 1.0]
                        currentIndex = 0
                    }
                    
                    Text(loadingText)
                        .font(.buttonStandard)
                        .foregroundStyle(.white)
                        .padding(.top)
                }
            }
        }
    }
    
    private func startPulsingAnimation() {
        guard isLoading else {
            return
        }
        
        withAnimation(.easeOut(duration: 0.3)) {
            dotScales[currentIndex] = 1.5
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeIn(duration: 0.3)) {
                dotScales[currentIndex] = 1.0
            }
            
            currentIndex = currentIndex == dotScales.count - 1 ? 0 : currentIndex + 1
            
            if isLoading {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    startPulsingAnimation()
                }
            }
        }
    }
}

#Preview {
    LoadingDotsView(
        isLoading: .constant(true)
    )
}
