//
//  FloatingTabBar.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2026-11-13.
//

import SwiftUI

struct FloatingTabItem: Identifiable {
    let tab: RootTab
    let title: String
    let systemImage: String
    let tint: Color
    var count: Int? = nil

    var id: RootTab { tab }
}

/// Floating capsule tab bar. The selected tab expands into a tinted pill (icon + label + optional
/// count) that slides between positions; unselected tabs are icon-only.
struct FloatingTabBar: View {
    let items: [FloatingTabItem]
    @Binding var selection: RootTab
    /// Minimized: only the selected tab's icon shows; tapping it expands the bar again
    var isCollapsed: Bool = false
    var onExpand: () -> Void = {}

    @Namespace private var pillNamespace

    var body: some View {
        HStack(spacing: Spacing.xs) {
            ForEach(items.filter { !isCollapsed || $0.tab == selection }) { item in
                itemButton(item)
            }
        }
        .padding(6)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(Capsule().stroke(Color.secondaryText.opacity(0.08), lineWidth: 1))
        )
        .shadow(color: Color.black.opacity(0.06), radius: 1, x: 0, y: 1)
        .shadow(color: Color.black.opacity(0.12), radius: 14, x: 0, y: 8)
        .sensoryFeedback(.selection, trigger: selection)
        .padding(.bottom, Spacing.xs)
    }

    private func itemButton(_ item: FloatingTabItem) -> some View {
        let isSelected = selection == item.tab

        let showsLabel = isSelected && !isCollapsed

        return Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                if isCollapsed {
                    onExpand()
                } else {
                    selection = item.tab
                }
            }
        } label: {
            HStack(spacing: Spacing.sm) {
                Image(systemName: isSelected ? "\(item.systemImage).fill" : item.systemImage)
                    .font(.system(size: 17, weight: .semibold))
                    .frame(width: 22, height: 22)

                if showsLabel {
                    Text(item.title)
                        .font(.chipLabel)
                        .fixedSize()
                        .transition(.opacity.combined(with: .scale(scale: 0.8, anchor: .leading)))

                    if let count = item.count {
                        Text("\(count)")
                            .font(.chipLabel)
                            .monospacedDigit()
                            .contentTransition(.numericText(value: Double(count)))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(item.tint.opacity(0.15)))
                            .transition(.opacity)
                    }
                }
            }
            .foregroundStyle(isSelected ? item.tint : Color.secondaryText.opacity(0.55))
            .padding(.horizontal, showsLabel ? Spacing.lg : Spacing.md)
            .padding(.vertical, 10)
            .background {
                if isSelected {
                    Capsule()
                        .fill(item.tint.opacity(0.14))
                        .matchedGeometryEffect(id: "pill", in: pillNamespace)
                }
            }
            .contentShape(Capsule())
        }
        .buttonStyle(PressScaleButtonStyle())
        .accessibilityLabel(isCollapsed ? "Show tabs" : (item.count.map { "\(item.title), \($0) invoices" } ?? item.title))
        .accessibilityAddTraits(isSelected ? [.isSelected, .isButton] : .isButton)
    }
}

#Preview {
    @Previewable @State var selection: RootTab = .rental

    VStack {
        Spacer()
        FloatingTabBar(
            items: [
                FloatingTabItem(tab: .home, title: "Home", systemImage: "square.grid.2x2", tint: .accentDeepOrange),
                FloatingTabItem(tab: .rental, title: "Rental", systemImage: "house", tint: .accentDeepOrange, count: 24),
                FloatingTabItem(tab: .retail, title: "Retail", systemImage: "bag", tint: .accentDeepRed, count: 112),
            ],
            selection: $selection
        )
    }
    .frame(maxWidth: .infinity)
    .background(Color.primarySurface)
}
