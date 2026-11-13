//
//  CategoryBarChart.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2026-11-13.
//

import SwiftUI

/// Vertical bars, one per category with spending, labelled underneath with icon + short name and
/// the amount on top. Each column is a toggle: selecting one dims the others; selecting it again
/// clears the selection.
struct CategoryBarChart: View {
    let segments: [(subType: RetailInvoiceSubType, amount: Double)]
    @Binding var selection: RetailInvoiceSubType?

    /// Height available to the tallest bar (amount label sits above it)
    var barAreaHeight: CGFloat = 120
    /// Bars never shrink below this, so tiny amounts stay visible and tappable
    private let minimumBarHeight: CGFloat = 6

    private var maxAmount: Double { segments.map(\.amount).max() ?? 0 }

    var body: some View {
        HStack(alignment: .bottom, spacing: Spacing.sm) {
            ForEach(segments, id: \.subType) { segment in
                column(segment)
            }
        }
        .animation(.snappy, value: selection)
        .animation(.snappy, value: segments.map(\.amount))
        .sensoryFeedback(.selection, trigger: selection)
    }

    private func column(_ segment: (subType: RetailInvoiceSubType, amount: Double)) -> some View {
        let subType = segment.subType
        let isSelected = selection == subType
        let isDimmed = selection != nil && !isSelected
        let fraction = maxAmount > 0 ? segment.amount / maxAmount : 0
        let barHeight = max(barAreaHeight * fraction, minimumBarHeight)

        return Button {
            selection = isSelected ? nil : subType
        } label: {
            VStack(spacing: Spacing.xs) {
                // Amount + bar, bottom-aligned within a fixed-height area so all bars share a baseline
                VStack(spacing: Spacing.xs) {
                    Spacer(minLength: 0)
                    Text(compactAmount(segment.amount))
                        .font(.chipLabel)
                        .foregroundStyle(Color.secondaryText.opacity(0.8))
                        .monospacedDigit()
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    UnevenRoundedRectangle(topLeadingRadius: 6, topTrailingRadius: 6)
                        .fill(subType.color)
                        .frame(height: barHeight)
                }
                .frame(height: barAreaHeight + 20)

                Image(systemName: subType.sfSymbolName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(subType.color)
                    .frame(height: 18)

                Text(subType.shortName)
                    .font(.chipLabel)
                    .fontWeight(isSelected ? .bold : .regular)
                    .foregroundStyle(isSelected ? subType.color : Color.secondaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .frame(maxWidth: 64)
            .frame(maxWidth: .infinity)
            .opacity(isDimmed ? 0.25 : 1)
            .contentShape(Rectangle())
        }
        .buttonStyle(PressScaleButtonStyle())
        .accessibilityLabel("\(subType.displayName), \(Utils.formatCurrency(segment.amount, currency: "SEK"))")
        .accessibilityAddTraits(isSelected ? [.isSelected, .isButton] : .isButton)
        .accessibilityHint(isSelected ? "Shows all invoices" : "Shows only \(subType.displayName) invoices")
    }

    /// Whole kronor, compacted above 10 000 so labels fit narrow columns (e.g. "12,3k")
    private func compactAmount(_ amount: Double) -> String {
        if amount >= 10_000 {
            return (amount / 1000).formatted(.number.precision(.fractionLength(1))) + "k"
        }
        return amount.rounded().formatted(.number.precision(.fractionLength(0)))
    }
}

#Preview {
    @Previewable @State var selection: RetailInvoiceSubType? = nil

    CategoryBarChart(
        segments: [
            (.utility, 6290),
            (.foodDelivery, 247),
            (.subscriptions, 200),
            (.travel, 38),
        ],
        selection: $selection
    )
    .padding()
    .background(Color.primarySurface)
}
