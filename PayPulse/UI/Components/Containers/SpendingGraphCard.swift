//
//  SpendingGraphCard.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2026-11-13.
//

import SwiftUI
import Charts

/// Home's snapshot card: the period's running total and a cumulative spending curve,
/// with optional rent baseline and a faint previous-period comparison line.
struct SpendingGraphCard: View {
    let isLoaded: Bool
    let total: Double
    let current: [SpendingPoint]
    let previous: [SpendingPoint]
    let todayProgress: Double
    let today: Date
    let hasRent: Bool
    let hasPrevious: Bool

    @Binding var includeRent: Bool
    @Binding var compareLastMonth: Bool

    private var showsPrevious: Bool { compareLastMonth && hasPrevious && !previous.isEmpty }

    private var yMax: Double {
        let currentMax = current.map(\.amount).max() ?? 0
        let previousMax = showsPrevious ? (previous.map(\.amount).max() ?? 0) : 0
        return max(max(currentMax, previousMax) * 1.15, 1)
    }

    /// Previous period's cumulative amount at the same point in the period as today.
    private var previousAtToday: Double? {
        guard showsPrevious else { return nil }
        return previous.last(where: { $0.progress <= todayProgress })?.amount
    }

    var body: some View {
        SoftCard(padding: Spacing.xl) {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                header
                chart
                toggles
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(isLoaded ? Utils.formatCurrency(total, currency: "SEK") : "-")
                .font(.headingMedium)
                .foregroundStyle(Color.accentDeepOrange)
                .monospacedDigit()
                .contentTransition(.numericText(value: total))

            HStack(spacing: Spacing.sm) {
                Text("Spent this month")
                    .font(.bodyStandard)
                    .foregroundStyle(Color.secondaryText)

                if let previousAtToday {
                    deltaLabel(current: total, previous: previousAtToday)
                        .transition(.opacity)
                }
            }
        }
    }

    private func deltaLabel(current: Double, previous: Double) -> some View {
        let delta = (current - previous).rounded()
        let symbol = delta > 0 ? "arrow.up" : (delta < 0 ? "arrow.down" : "equal")
        return HStack(spacing: 2) {
            Image(systemName: symbol)
            Text("\(Utils.formatCurrency(abs(delta), currency: "SEK")) vs. last month")
        }
        .font(.chipLabel)
        .foregroundStyle(Color.secondaryText.opacity(0.7))
        .lineLimit(1)
        .minimumScaleFactor(0.8)
    }

    // MARK: - Chart

    private var chart: some View {
        Chart {
            if showsPrevious {
                ForEach(previous) { point in
                    LineMark(
                        x: .value("Progress", point.progress),
                        y: .value("Amount", point.amount),
                        series: .value("Series", "previous")
                    )
                    .interpolationMethod(.monotone)
                    .foregroundStyle(Color.secondaryText.opacity(0.3))
                    .lineStyle(StrokeStyle(lineWidth: 1.5, lineCap: .round))
                }
            }

            ForEach(current) { point in
                AreaMark(
                    x: .value("Progress", point.progress),
                    y: .value("Amount", point.amount),
                    series: .value("Series", "current")
                )
                .interpolationMethod(.monotone)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.accentDeepOrange.opacity(0.35), Color.accentDeepOrange.opacity(0.0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

                LineMark(
                    x: .value("Progress", point.progress),
                    y: .value("Amount", point.amount),
                    series: .value("Series", "current")
                )
                .interpolationMethod(.monotone)
                .foregroundStyle(Color.accentDeepOrange)
                .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
            }

            RuleMark(x: .value("Today", todayProgress))
                .foregroundStyle(Color.secondaryText.opacity(0.5))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [3, 3]))
                .annotation(
                    position: .bottom,
                    alignment: .center,
                    spacing: Spacing.xs,
                    overflowResolution: .init(x: .fit(to: .chart), y: .disabled)
                ) {
                    Text(today, format: .dateTime.day().month(.abbreviated))
                        .font(.chipLabel)
                        .foregroundStyle(Color.secondaryText.opacity(0.8))
                }
        }
        .chartXScale(domain: 0...1)
        .chartYScale(domain: 0...yMax)
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartLegend(.hidden)
        .frame(height: 180)
        .padding(.bottom, Spacing.lg) // room for the today label
        .opacity(isLoaded ? 1 : 0.3)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Spending this month")
        .accessibilityValue(Utils.formatCurrency(total, currency: "SEK"))
    }

    // MARK: - Toggles

    private var toggles: some View {
        HStack(spacing: Spacing.sm) {
            if hasRent {
                ToggleChip(title: "Include rent", systemImage: "house", isOn: $includeRent)
            }
            if hasPrevious {
                ToggleChip(title: "vs. last month", systemImage: "chart.line.uptrend.xyaxis", isOn: $compareLastMonth)
            }
            Spacer(minLength: 0)
        }
    }
}

// MARK: - Toggle Chip

private struct ToggleChip: View {
    let title: String
    let systemImage: String
    @Binding var isOn: Bool

    var body: some View {
        Button {
            withAnimation(.snappy) { isOn.toggle() }
        } label: {
            Label(title, systemImage: systemImage)
                .font(.chipLabel)
                .foregroundStyle(isOn ? Color.accentDeepOrange : Color.secondaryText.opacity(0.7))
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                .background(
                    Capsule()
                        .fill(isOn ? Color.accentDeepOrange.opacity(0.14) : Color.secondaryText.opacity(0.06))
                )
                .overlay(
                    Capsule()
                        .stroke(isOn ? Color.accentDeepOrange.opacity(0.35) : Color.clear, lineWidth: 1)
                )
        }
        .buttonStyle(PressScaleButtonStyle())
        .sensoryFeedback(.selection, trigger: isOn)
        .accessibilityAddTraits(isOn ? .isSelected : [])
    }
}

#Preview {
    @Previewable @State var includeRent = true
    @Previewable @State var compare = true
    let current = (0...13).map { SpendingPoint(progress: Double($0) / 30, amount: 9800 + Double($0 * $0) * 20) }
    let previous = (0...30).map { SpendingPoint(progress: Double($0) / 30, amount: 9800 + Double($0) * 180) }

    SpendingGraphCard(
        isLoaded: true,
        total: 13_380,
        current: current,
        previous: previous,
        todayProgress: 13.0 / 30,
        today: Date(),
        hasRent: true,
        hasPrevious: true,
        includeRent: $includeRent,
        compareLastMonth: $compare
    )
    .padding()
    .background(Color.primarySurface)
}
