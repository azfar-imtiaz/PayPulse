//
//  ScreenHeader.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2026-11-13.
//

import SwiftUI

/// The large title block at the top of each root tab (Home, Rental, Retail), so position and
/// size stay identical across tabs. `trailing` holds a single action (profile, refresh...).
struct ScreenHeader<Trailing: View>: View {
    enum Style {
        /// On the page background (Home, Retail)
        case standard
        /// On the dark header banner (Rental's year list)
        case onBanner
    }

    let title: String
    var subtitle: String? = nil
    var style: Style = .standard
    /// Pushed screens put their back button in the title row instead of a nav bar
    var showsBackButton: Bool = false
    @ViewBuilder var trailing: Trailing

    private var titleColor: Color {
        style == .onBanner ? .primarySurface : .secondaryText
    }

    private var subtitleColor: Color {
        style == .onBanner ? Color.primarySurface.opacity(0.6) : .gray
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: Spacing.md) {
                if showsBackButton {
                    BackButton(inverted: style == .onBanner)
                }

                Text(title)
                    .font(.headingLarge)
                    .foregroundStyle(titleColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .accessibilityAddTraits(.isHeader)

                Spacer(minLength: Spacing.md)

                trailing
            }

            if let subtitle {
                Text(subtitle)
                    .font(.headingStandard)
                    .foregroundStyle(subtitleColor)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.top, Spacing.xl)
        .padding(.bottom)
    }
}

extension ScreenHeader where Trailing == EmptyView {
    init(title: String, subtitle: String? = nil, style: Style = .standard, showsBackButton: Bool = false) {
        self.init(title: title, subtitle: subtitle, style: style, showsBackButton: showsBackButton) { EmptyView() }
    }
}

#Preview {
    VStack(spacing: 0) {
        ScreenHeader(title: "PayPulse", subtitle: "All your invoices, one place.") {
            Image(systemName: "person")
        }
        ScreenHeader(title: "Your rental invoices", style: .onBanner) {
            Image(systemName: "arrow.clockwise")
                .foregroundStyle(Color.primarySurface)
        }
        .background(Color.invoiceHeaderBannerBackground)
        Spacer()
    }
    .background(Color.primarySurface)
}
