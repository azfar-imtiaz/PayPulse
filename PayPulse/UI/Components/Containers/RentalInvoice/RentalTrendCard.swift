//
//  RentalTrendCard.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2026-11-13.
//

import SwiftUI
import Charts
import OrderedCollections

/// Summary card at the top of the rental list: the selected year's total rent, monthly average,
/// and a month-by-month line on a fixed Jan–Dec axis, with an optional faint previous-year line.
struct RentalTrendCard: View {
    let yearlyInvoices: OrderedDictionary<Int, [RentalInvoice]>
    let selectedYear: Int
    @Binding var comparePreviousYear: Bool

    struct MonthPoint: Identifiable, Hashable {
        let month: Int
        let amount: Int
        var id: Int { month }
    }

    private static func points(for invoices: [RentalInvoice]?) -> [MonthPoint] {
        guard let invoices else { return [] }
        var byMonth: [Int: Int] = [:]
        for invoice in invoices {
            guard let month = Int(invoice.dueDateMonth), (1...12).contains(month) else { continue }
            byMonth[month, default: 0] += invoice.totalAmount
        }
        return byMonth.keys.sorted().map { MonthPoint(month: $0, amount: byMonth[$0] ?? 0) }
    }

    private var current: [MonthPoint] { Self.points(for: yearlyInvoices[selectedYear]) }
    private var previous: [MonthPoint] { Self.points(for: yearlyInvoices[selectedYear - 1]) }
    private var hasPrevious: Bool { !previous.isEmpty }
    private var showsPrevious: Bool { comparePreviousYear && hasPrevious }

    private var total: Int { current.reduce(0) { $0 + $1.amount } }
    private var average: Double { current.isEmpty ? 0 : Double(total) / Double(current.count) }

    private var yDomain: ClosedRange<Double> {
        // Include last year even when its line is hidden, so the toggle doesn't rescale this year's line
        let values = (current + previous).map { Double($0.amount) }
        guard let lo = values.min(), let hi = values.max() else { return 0...1 }
        // Rent is flat-ish: zoom in on the band it moves in so changes are visible
        let pad = max((hi - lo) * 0.25, hi * 0.03, 1)
        return max(lo - pad, 0)...(hi + pad)
    }

    var body: some View {
        SoftCard(padding: Spacing.xl) {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                header
                chart
                HStack(spacing: Spacing.sm) {
                    if hasPrevious {
                        ToggleChip(
                            title: "vs. \(String(selectedYear - 1))",
                            systemImage: "chart.line.uptrend.xyaxis",
                            isOn: $comparePreviousYear
                        )
                    }
                    Spacer(minLength: 0)
                    HStack(spacing: 4) {
                        Text("Charts")
                        Image(systemName: "chevron.right")
                    }
                    .font(.chipLabel)
                    .foregroundStyle(Color.secondaryText.opacity(0.6))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(Utils.formatCurrency(Double(total), currency: "SEK"))
                .font(.headingMedium)
                .foregroundStyle(Color.accentDeepOrange)
                .monospacedDigit()
                .contentTransition(.numericText(value: Double(total)))

            // The longer label + average don't always fit on one line: wrap the average below if needed
            ViewThatFits(in: .horizontal) {
                HStack(spacing: Spacing.sm) {
                    subtitleLabel
                    averageLabel
                }
                VStack(alignment: .leading, spacing: 2) {
                    subtitleLabel
                    averageLabel
                }
            }
        }
    }

    private var subtitleLabel: some View {
        Text("Total rent paid in \(String(selectedYear))")
            .font(.bodyStandard)
            .foregroundStyle(Color.secondaryText)
            .lineLimit(1)
    }

    @ViewBuilder
    private var averageLabel: some View {
        if !current.isEmpty {
            Text("≈ \(Utils.formatCurrency(average.rounded(), currency: "SEK"))/month")
                .font(.chipLabel)
                .foregroundStyle(Color.secondaryText.opacity(0.7))
                .monospacedDigit()
                .lineLimit(1)
        }
    }

    // MARK: - Chart

    private var chart: some View {
        Chart {
            if showsPrevious {
                previousLine
            }
            currentArea
            currentLine
            latestPoint
        }
        .chartXScale(domain: 1...12)
        .chartYScale(domain: yDomain)
        // The compare toggle is @AppStorage (updates arrive outside withAnimation), so animate on the values
        .animation(.smooth(duration: 0.45), value: comparePreviousYear)
        .animation(.smooth(duration: 0.45), value: selectedYear)
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartLegend(.hidden)
        .frame(height: 120)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Total rent paid in \(String(selectedYear))")
        .accessibilityValue("Total \(Utils.formatCurrency(Double(total), currency: "SEK")), \(current.count) invoices")
    }

    // MARK: - Chart content

    private var areaGradient: LinearGradient {
        LinearGradient(
            colors: [Color.accentDeepOrange.opacity(0.3), Color.accentDeepOrange.opacity(0.0)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    @ChartContentBuilder
    private var previousLine: some ChartContent {
        ForEach(previous) { point in
            LineMark(
                x: .value("Month", point.month),
                y: .value("Amount", point.amount),
                series: .value("Series", "previous")
            )
            .interpolationMethod(.monotone)
            .foregroundStyle(Color.secondaryText.opacity(0.3))
            .lineStyle(StrokeStyle(lineWidth: 1.5, lineCap: .round))
        }
    }

    @ChartContentBuilder
    private var currentArea: some ChartContent {
        let base = yDomain.lowerBound
        ForEach(current) { point in
            AreaMark(
                x: .value("Month", point.month),
                yStart: .value("Base", base),
                yEnd: .value("Amount", Double(point.amount)),
                series: .value("Series", "current")
            )
            .interpolationMethod(.monotone)
            .foregroundStyle(areaGradient)
        }
    }

    @ChartContentBuilder
    private var currentLine: some ChartContent {
        ForEach(current) { point in
            LineMark(
                x: .value("Month", point.month),
                y: .value("Amount", point.amount),
                series: .value("Series", "current")
            )
            .interpolationMethod(.monotone)
            .foregroundStyle(Color.accentDeepOrange)
            .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
        }
    }

    /// A single invoice can't draw a line — show it as a point; also marks the latest month
    @ChartContentBuilder
    private var latestPoint: some ChartContent {
        if let last = current.last {
            PointMark(x: .value("Month", last.month), y: .value("Amount", last.amount))
                .foregroundStyle(Color.accentDeepOrange)
                .symbolSize(40)
        }
    }
}

#Preview {
    @Previewable @State var compare = true
    let make: (Int, Int, Int) -> RentalInvoice = { year, month, amount in
        RentalInvoice(invoiceID: "\(year)-\(month)", filename: "", hyra: amount, el: 0, kallvatten: 0, varmvatten: 0,
                      totalAmount: amount, dueDateMonth: String(month), dueDateYear: String(year),
                      dueDate: "", moms: 0, ocr: "")
    }
    let data: OrderedDictionary<Int, [RentalInvoice]> = [
        2026: (1...10).map { make(2026, $0, 6100 + ($0 % 4) * 60) },
        2025: (1...12).map { make(2025, $0, 5900 + ($0 % 3) * 80) },
    ]

    RentalTrendCard(yearlyInvoices: data, selectedYear: 2026, comparePreviousYear: $compare)
        .padding()
        .background(Color.primarySurface)
}
