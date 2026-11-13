//
//  SpendingSeries.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2026-11-13.
//

import Foundation

// MARK: - Spending Point

/// One point on the cumulative spending curve.
/// `progress` is how far through the period the point sits (0 = start, 1 = end), so periods
/// of different lengths (30 vs 31 days) overlay correctly on the same chart.
struct SpendingPoint: Identifiable, Hashable {
    /// Stable identity across rebuilds: 0 = period start, n = end of day n. Charts match points by
    /// id when animating, so this must not depend on the exact time the series was built.
    let index: Int
    let progress: Double
    let amount: Double

    var id: Int { index }
}

// MARK: - Spending Period

/// A half-open date range [start, end). Calendar months today; designed so a custom
/// start-day period (e.g. 25th → 25th) can be added later without touching the chart.
struct SpendingPeriod: Equatable {
    let start: Date
    let end: Date

    private static var calendar: Calendar { Calendar.current }

    static func calendarMonth(containing date: Date) -> SpendingPeriod {
        let cal = calendar
        let start = cal.dateInterval(of: .month, for: date)?.start ?? cal.startOfDay(for: date)
        let end = cal.date(byAdding: .month, value: 1, to: start) ?? start
        return SpendingPeriod(start: start, end: end)
    }

    func previous() -> SpendingPeriod {
        let cal = Self.calendar
        let prevStart = cal.date(byAdding: .month, value: -1, to: start) ?? start
        return SpendingPeriod(start: prevStart, end: start)
    }

    func next() -> SpendingPeriod {
        let cal = Self.calendar
        let nextEnd = cal.date(byAdding: .month, value: 1, to: end) ?? end
        return SpendingPeriod(start: end, end: nextEnd)
    }

    /// Number of whole days in the period.
    var dayCount: Int {
        max(Self.calendar.dateComponents([.day], from: start, to: end).day ?? 1, 1)
    }

    /// Fraction of the period elapsed at `date`, clamped to 0…1.
    func progress(for date: Date) -> Double {
        let total = end.timeIntervalSince(start)
        guard total > 0 else { return 0 }
        return min(max(date.timeIntervalSince(start) / total, 0), 1)
    }

    /// The `month` query value the summary endpoint expects for this period (yyyy-MM).
    var monthParameter: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: start)
    }
}

// MARK: - Series Builder

enum SpendingSeries {
    private static let itemDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    /// Builds a cumulative daily spending curve for `period`, from its start through `through`
    /// (clamped to the period end). Rent, when given, is added as a baseline from day 0.
    static func build(
        items: [InvoiceSummaryItem],
        rentAmount: Double?,
        period: SpendingPeriod,
        through: Date
    ) -> [SpendingPoint] {
        let cal = Calendar.current
        let baseline = rentAmount ?? 0

        // Sum spending per day index within the period
        var spendByDay: [Int: Double] = [:]
        for item in items {
            guard let date = itemDateFormatter.date(from: item.invoiceDate),
                  date >= period.start, date < period.end else { continue }
            let day = cal.dateComponents([.day], from: period.start, to: cal.startOfDay(for: date)).day ?? 0
            spendByDay[day, default: 0] += item.totalAmount
        }

        let days = period.dayCount
        let endProgress = period.progress(for: through)
        // Last day index whose start is at or before `through`
        let lastDay = min(Int((endProgress * Double(days)).rounded(.down)), days - 1)

        var points: [SpendingPoint] = [SpendingPoint(index: 0, progress: 0, amount: baseline)]
        var running = baseline
        if lastDay >= 0 {
            for day in 0...lastDay {
                running += spendByDay[day] ?? 0
                // Each day's spending lands at the end of that day
                let progress = min(Double(day + 1) / Double(days), endProgress)
                if let last = points.last, progress <= last.progress {
                    // `through` sits exactly on a day boundary: fold into the previous point
                    points[points.count - 1] = SpendingPoint(index: last.index, progress: last.progress, amount: running)
                } else {
                    points.append(SpendingPoint(index: day + 1, progress: progress, amount: running))
                }
            }
        }
        return points
    }
}
