//
//  LoadingDotsView.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-07-07.
//

import SwiftUI

struct LoadingDotsView: View {
    @Binding var isLoading : Bool
    var loadingText : String = "Loading..."

    var body: some View {
        ZStack {
            if isLoading {
                Color.black.opacity(0.78)
                    .ignoresSafeArea(edges: .all)

                VStack(spacing: Spacing.xl) {
                    PulseRingsView()

                    Text(loadingText.uppercased())
                        .font(.footnote)
                        .tracking(0.5)
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.6), radius: 3, x: 0, y: 1)
                }
            }
        }
    }
}

private struct PulseRingsView: View {
    @State private var animate = false

    private let ringCount = 3
    private let ringDelay = 0.6
    private let ringDuration = 2.4
    private let ringSize: CGFloat = 88
    private let coreSize: CGFloat = 34

    var body: some View {
        ZStack {
            ForEach(0..<ringCount, id: \.self) { index in
                Circle()
                    .stroke(style: StrokeStyle(lineWidth: 2.5, dash: [1, 6]))
                    .foregroundStyle(Color.accentDeepOrange)
                    .frame(width: ringSize, height: ringSize)
                    .scaleEffect(animate ? 1 : 0.35)
                    .opacity(animate ? 0 : 0.55)
                    .rotationEffect(.degrees(animate ? 35 : 0))
                    .animation(
                        .easeOut(duration: ringDuration)
                        .repeatForever(autoreverses: false)
                        .delay(Double(index) * ringDelay),
                        value: animate
                    )
            }

            Circle()
                .fill(Color.accentDeepOrange)
                .frame(width: coreSize, height: coreSize)
                .shadow(color: Color.accentDeepOrange.opacity(0.55), radius: 10, x: 0, y: 4)
                .scaleEffect(animate ? 1.12 : 1.0)
                .animation(
                    .easeInOut(duration: 1.2)
                    .repeatForever(autoreverses: true),
                    value: animate
                )
        }
        .frame(width: ringSize, height: ringSize)
        .onAppear {
            animate = true
        }
        .onDisappear {
            animate = false
        }
    }
}

#Preview {
    LoadingDotsView(
        isLoading: .constant(true),
        loadingText: "Fetching invoices..."
    )
}
