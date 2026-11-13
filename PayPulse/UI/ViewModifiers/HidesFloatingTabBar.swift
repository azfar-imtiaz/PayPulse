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
    /// Minimized to a small pill while the user scrolls down a tab's content
    @Published var isCollapsed = false
    /// Expanded bar height, measured by the root; scroll views reserve this much bottom margin
    @Published var barHeight: CGFloat = 0

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

// MARK: - Scroll behaviour

private struct ScrollMetrics: Equatable {
    var offset: CGFloat
    var maxOffset: CGFloat
}

private struct FloatingTabBarScrollModifier: ViewModifier {
    @EnvironmentObject private var visibility: FloatingTabBarVisibility

    /// How far the user must scroll in one direction before the bar changes state
    private let travelThreshold: CGFloat = 28
    /// Always keep the bar expanded near the top of the content
    private let topZone: CGFloat = 24

    /// Turning point of the current scroll direction: the shallowest offset while expanded,
    /// the deepest while collapsed. Measuring travel from it ignores per-frame jitter.
    @State private var anchor: CGFloat = 0

    func body(content: Content) -> some View {
        content
            // Reserve room so the last item can scroll fully clear of the (expanded) bar
            .contentMargins(.bottom, visibility.barHeight, for: .scrollContent)
            .onScrollGeometryChange(for: ScrollMetrics.self) { geometry in
                ScrollMetrics(
                    offset: geometry.contentOffset.y + geometry.contentInsets.top,
                    maxOffset: geometry.contentSize.height + geometry.contentInsets.top
                        + geometry.contentInsets.bottom - geometry.containerSize.height
                )
            } action: { old, new in
                update(from: old, to: new)
            }
    }

    private func update(from old: ScrollMetrics, to new: ScrollMetrics) {
        let offset = new.offset

        if offset <= topZone {
            anchor = offset
            setCollapsed(false)
            return
        }
        // Rubber-banding past the bottom: leave the bar as it is
        guard offset < new.maxOffset else { return }

        if visibility.isCollapsed {
            anchor = max(anchor, offset)
            if anchor - offset > travelThreshold {
                anchor = offset
                setCollapsed(false)
            }
        } else {
            anchor = min(anchor, offset)
            if offset - anchor > travelThreshold {
                anchor = offset
                setCollapsed(true)
            }
        }
    }

    private func setCollapsed(_ collapsed: Bool) {
        guard collapsed != visibility.isCollapsed else { return }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            visibility.isCollapsed = collapsed
        }
    }
}

extension View {
    /// Apply to a root tab's main scroll view: reserves bottom space for the floating tab bar and
    /// minimizes the bar while scrolling down, restoring it on scroll up or near the top.
    func floatingTabBarScrollBehavior() -> some View {
        modifier(FloatingTabBarScrollModifier())
    }
}
