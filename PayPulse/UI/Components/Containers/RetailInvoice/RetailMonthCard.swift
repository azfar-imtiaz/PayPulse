//
//  RetailMonthCard.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2026-11-13.
//

import SwiftUI

/// Retail tab's month card: total retail spend for the period, change vs. the same point last
/// period, and a single bar split by category (width = share of spend) with a legend.
struct RetailMonthCard: View {
    let isLoaded: Bool
    let monthName: String
    let total: Double
    let previousAtSamePoint: Double?
    let segments: [(subType: RetailInvoiceSubType, amount: Double)]
    /// Shows the "See invoices ›" hint when the card is tappable
    var showsDisclosure: Bool = false

    private func share(_ amount: Double) -> Double {
        total > 0 ? amount / total : 0
    }

    var body: some View {
        SoftCard(padding: Spacing.xl) {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                header
                bar
                if !segments.isEmpty {
                    legend
                }
                if showsDisclosure {
                    HStack(spacing: 4) {
                        Spacer()
                        Text("See invoices")
                        Image(systemName: "chevron.right")
                    }
                    .font(.chipLabel)
                    .foregroundStyle(Color.secondaryText.opacity(0.6))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(isLoaded ? Utils.formatCurrency(total.rounded(), currency: "SEK") : "-")
                .font(.headingMedium)
                .foregroundStyle(Color.accentDeepRed)
                .monospacedDigit()
                .contentTransition(.numericText(value: total))

            // Subtitle and comparison share a line when they fit, otherwise the comparison wraps below
            ViewThatFits(in: .horizontal) {
                HStack(spacing: Spacing.sm) {
                    subtitleLabel
                    comparisonLabel
                }
                VStack(alignment: .leading, spacing: 2) {
                    subtitleLabel
                    comparisonLabel
                }
            }
        }
    }

    private var subtitleLabel: some View {
        Text("Spent on retail in \(monthName)")
            .font(.bodyStandard)
            .foregroundStyle(Color.secondaryText)
            .lineLimit(1)
    }

    @ViewBuilder
    private var comparisonLabel: some View {
        if let previousAtSamePoint {
            deltaLabel(previous: previousAtSamePoint)
        }
    }

    private func deltaLabel(previous: Double) -> some View {
        let delta = (total - previous).rounded()
        let symbol = delta > 0 ? "arrow.up" : (delta < 0 ? "arrow.down" : "equal")
        return HStack(spacing: 2) {
            Image(systemName: symbol)
            Text("\(Utils.formatCurrency(abs(delta), currency: "SEK")) vs. last month")
        }
        .font(.chipLabel)
        .foregroundStyle(Color.secondaryText.opacity(0.7))
        .monospacedDigit()
        .lineLimit(1)
        .accessibilityLabel("\(Utils.formatCurrency(abs(delta), currency: "SEK")) \(delta >= 0 ? "more" : "less") than this point last month")
    }

    // MARK: - Split bar

    private var bar: some View {
        CategorySplitBar(segments: segments)
    }

    // MARK: - Legend

    private var legend: some View {
        FlowLayout(spacing: Spacing.md, lineSpacing: Spacing.sm) {
            ForEach(segments, id: \.subType) { segment in
                HStack(spacing: 6) {
                    Circle()
                        .fill(segment.subType.color)
                        .frame(width: 8, height: 8)
                    Text(segment.subType.displayName)
                        .foregroundStyle(Color.secondaryText)
                    Text("\(Int((share(segment.amount) * 100).rounded()))%")
                        .foregroundStyle(Color.secondaryText.opacity(0.6))
                        .monospacedDigit()
                }
                .font(.chipLabel)
            }
        }
    }
}

// MARK: - Category split bar

/// One horizontal bar split into category colours; each segment's width is its share of the total.
struct CategorySplitBar: View {
    let segments: [(subType: RetailInvoiceSubType, amount: Double)]
    var height: CGFloat = 14

    private var total: Double { segments.reduce(0) { $0 + $1.amount } }

    var body: some View {
        GeometryReader { proxy in
            let gap: CGFloat = 2
            let available = proxy.size.width - gap * CGFloat(max(segments.count - 1, 0))

            HStack(spacing: gap) {
                if segments.isEmpty || total <= 0 {
                    Rectangle()
                        .fill(Color.secondaryText.opacity(0.08))
                } else {
                    ForEach(segments, id: \.subType) { segment in
                        Rectangle()
                            .fill(segment.subType.color)
                            .frame(width: max(available * segment.amount / total, 3))
                    }
                }
            }
            .clipShape(Capsule())
        }
        .frame(height: height)
        .animation(.snappy, value: segments.map(\.amount))
        .accessibilityHidden(true)
    }
}

// MARK: - Flow layout

/// Lays children out left to right, wrapping onto new lines when the row is full.
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    var lineSpacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = arrange(width: proposal.width ?? .infinity, subviews: subviews)
        let height = rows.map(\.height).reduce(0, +) + lineSpacing * CGFloat(max(rows.count - 1, 0))
        let width = rows.map(\.width).max() ?? 0
        return CGSize(width: proposal.width ?? width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var y = bounds.minY
        for row in arrange(width: bounds.width, subviews: subviews) {
            var x = bounds.minX
            for index in row.indices {
                let size = subviews[index].sizeThatFits(.unspecified)
                subviews[index].place(at: CGPoint(x: x, y: y + (row.height - size.height) / 2), proposal: .unspecified)
                x += size.width + spacing
            }
            y += row.height + lineSpacing
        }
    }

    private struct Row {
        var indices: [Int] = []
        var width: CGFloat = 0
        var height: CGFloat = 0
    }

    private func arrange(width: CGFloat, subviews: Subviews) -> [Row] {
        var rows: [Row] = []
        var current = Row()
        for index in subviews.indices {
            let size = subviews[index].sizeThatFits(.unspecified)
            let needed = current.indices.isEmpty ? size.width : current.width + spacing + size.width
            if needed > width, !current.indices.isEmpty {
                rows.append(current)
                current = Row()
            }
            current.width = current.indices.isEmpty ? size.width : current.width + spacing + size.width
            current.height = max(current.height, size.height)
            current.indices.append(index)
        }
        if !current.indices.isEmpty { rows.append(current) }
        return rows
    }
}

#Preview {
    RetailMonthCard(
        isLoaded: true,
        monthName: "November",
        total: 4812,
        previousAtSamePoint: 6052,
        segments: [
            (.foodDelivery, 1840),
            (.technology, 1290),
            (.subscriptions, 820),
            (.grocery, 580),
            (.miscellaneous, 282),
        ]
    )
    .padding()
    .background(Color.primarySurface)
}
