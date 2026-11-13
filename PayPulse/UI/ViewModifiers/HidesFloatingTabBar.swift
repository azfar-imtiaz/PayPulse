//
//  HidesFloatingTabBar.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2026-11-13.
//

import SwiftUI

/// Shared visibility state for the custom `FloatingTabBar`. Screens that want the bar hidden
/// register while on screen; a count (rather than a Bool) keeps nested/overlapping pushes correct.
final class FloatingTabBarVisibility: ObservableObject {
    @Published private(set) var hideRequests = 0

    var isVisible: Bool { hideRequests == 0 }

    func requestHide() { hideRequests += 1 }
    func releaseHide() { hideRequests = max(hideRequests - 1, 0) }
}

private struct HidesFloatingTabBarModifier: ViewModifier {
    @EnvironmentObject private var visibility: FloatingTabBarVisibility
    @State private var isRegistered = false

    func body(content: Content) -> some View {
        content
            .onAppear {
                guard !isRegistered else { return }
                isRegistered = true
                withAnimation(.snappy) { visibility.requestHide() }
            }
            .onDisappear {
                guard isRegistered else { return }
                isRegistered = false
                withAnimation(.snappy) { visibility.releaseHide() }
            }
    }
}

extension View {
    /// Hides the root floating tab bar while this view is on screen (e.g. a pushed full-screen view).
    func hidesFloatingTabBar() -> some View {
        modifier(HidesFloatingTabBarModifier())
    }
}
