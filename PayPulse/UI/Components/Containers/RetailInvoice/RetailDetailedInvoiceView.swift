//
//  RetailDetailedInvoiceView.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-02-08.
//

import SwiftUI

struct RetailDetailedInvoiceItemsView: View {
    let detailInvoice: any RetailInvoiceDetail
    let subType: RetailInvoiceSubType
    let baseCurrency: String

    var body: some View {
        Group {
            switch subType {
            case .foodDelivery:
                if let foodDeliveryDetail = detailInvoice as? FoodDeliveryDetail {
                    FoodDeliveryItemsView(detail: foodDeliveryDetail, baseCurrency: baseCurrency)
                } else {
                    Text("Error: Could not display food delivery details")
                        .font(.bodyStandard)
                        .foregroundStyle(Color.accentDeepRed)
                }
            case .miscellaneous:
                if let miscellaneousDetail = detailInvoice as? MiscellaneousDetail {
                    MiscellaneousItemsView(detail: miscellaneousDetail, baseCurrency: baseCurrency)
                } else {
                    Text("Error: Could not display miscellaneous details")
                        .font(.bodyStandard)
                        .foregroundStyle(Color.accentDeepRed)
                }
            default:
                // For other sub-types that don't have detail implementations yet
                InvoiceDetailsContainer {
                    Text("Additional details not yet available for \(subType.displayName)")
                        .font(.bodyStandard)
                        .foregroundColor(.gray)
                        .padding()
                }
            }
        }
    }
}

struct RetailDetailedInvoiceSummaryView: View {
    let detailInvoice: any RetailInvoiceDetail
    let subType: RetailInvoiceSubType
    let baseCurrency: String

    var body: some View {
        Group {
            switch subType {
            case .foodDelivery:
                if let foodDeliveryDetail = detailInvoice as? FoodDeliveryDetail {
                    FoodDeliverySummaryView(detail: foodDeliveryDetail, baseCurrency: baseCurrency)
                } else {
                    Text("Error: Could not display food delivery summary")
                        .font(.bodyStandard)
                        .foregroundStyle(Color.accentDeepRed)
                }
            case .miscellaneous:
                if let miscellaneousDetail = detailInvoice as? MiscellaneousDetail {
                    MiscellaneousSummaryView(detail: miscellaneousDetail, baseCurrency: baseCurrency)
                } else {
                    Text("Error: Could not display miscellaneous summary")
                        .font(.bodyStandard)
                        .foregroundStyle(Color.accentDeepRed)
                }
            default:
                // For other sub-types, no summary available
                EmptyView()
            }
        }
    }
}

// MARK: - Food Delivery Items View

private struct FoodDeliveryItemsView: View {
    let detail: FoodDeliveryDetail
    let baseCurrency: String

    var body: some View {
        InvoiceDetailsContainer {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(detail.items.indices, id: \.self) { index in
                    let item = detail.items[index]

                    if index > 0 {
                        Divider()
                    }

                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.name)
                                .font(.bodyStandard)
                                .foregroundColor(.primary)

                            if let description = item.description, !description.isEmpty {
                                Text(description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            Text(item.getFormattedPrice())
                                .font(.bodyStandard)
                                .foregroundColor(.primary)

                            Text(formatCurrency(item.getTotalPrice(), currency: baseCurrency))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Food Delivery Summary View

private struct FoodDeliverySummaryView: View {
    let detail: FoodDeliveryDetail
    let baseCurrency: String

    var body: some View {
        InvoiceDetailsContainer {
            VStack(spacing: 8) {
                KeyStringValueRow(
                    key: "Subtotal",
                    value: formatCurrency(detail.getSubtotal(), currency: baseCurrency)
                )

                if detail.deliveryFee > 0 {
                    Divider()
                    KeyStringValueRow(
                        key: "Delivery Fee",
                        value: formatCurrency(detail.deliveryFee, currency: baseCurrency)
                    )
                }

                if detail.discount > 0 {
                    Divider()
                    KeyStringValueRow(
                        key: "Discount",
                        value: formatCurrency(-detail.discount, currency: baseCurrency)
                    )
                }

                Divider()
                KeyStringValueRow(
                    key: "Calculated Total",
                    value: formatCurrency(detail.getTotal(), currency: baseCurrency)
                )
            }
        }
    }
}

// MARK: - Miscellaneous Items View

private struct MiscellaneousItemsView: View {
    let detail: MiscellaneousDetail
    let baseCurrency: String

    var body: some View {
        VStack(spacing: 16) {
            // Items section
            InvoiceDetailsContainer {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(detail.items.indices, id: \.self) { index in
                        let item = detail.items[index]

                        if index > 0 {
                            Divider()
                        }

                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.name)
                                    .font(.bodyStandard)
                                    .foregroundColor(.primary)
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 2) {
                                Text(item.getFormattedPrice())
                                    .font(.bodyStandard)
                                    .foregroundColor(.primary)

                                Text(formatCurrency(item.getTotalPrice(), currency: baseCurrency))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }

            // Additional info section (if any fields are present)
            if detail.category != nil || detail.description != nil || detail.notes != nil {
                InvoiceDetailsContainer {
                    VStack(alignment: .leading, spacing: 8) {
                        if let category = detail.category, !category.isEmpty {
                            KeyStringValueRow(
                                key: "Category",
                                value: category
                            )
                            if detail.description != nil || detail.notes != nil {
                                Divider()
                            }
                        }

                        if let description = detail.description, !description.isEmpty {
                            KeyStringValueRow(
                                key: "Description",
                                value: description
                            )
                            if detail.notes != nil {
                                Divider()
                            }
                        }

                        if let notes = detail.notes, !notes.isEmpty {
                            KeyStringValueRow(
                                key: "Notes",
                                value: notes
                            )
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Miscellaneous Summary View

private struct MiscellaneousSummaryView: View {
    let detail: MiscellaneousDetail
    let baseCurrency: String

    var body: some View {
        InvoiceDetailsContainer {
            VStack(spacing: 8) {
                KeyStringValueRow(
                    key: "Subtotal",
                    value: formatCurrency(detail.getSubtotal(), currency: baseCurrency)
                )

                if detail.deliveryFee > 0 {
                    Divider()
                    KeyStringValueRow(
                        key: "Delivery Fee",
                        value: formatCurrency(detail.deliveryFee, currency: baseCurrency)
                    )
                }

                if detail.tax > 0 {
                    Divider()
                    KeyStringValueRow(
                        key: "Tax",
                        value: formatCurrency(detail.tax, currency: baseCurrency)
                    )
                }

                Divider()
                KeyStringValueRow(
                    key: "Calculated Total",
                    value: formatCurrency(detail.getTotal(), currency: baseCurrency)
                )
            }
        }
    }
}

// MARK: - Helper Functions

/// Formats a currency amount using proper currency formatting
private func formatCurrency(_ amount: Double, currency: String) -> String {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .currency

    // Map currency symbols/codes to proper ISO currency codes and locales
    let currencyCode = mapCurrencyToCode(currency)
    let locale = getLocaleForCurrency(currencyCode)

    numberFormatter.currencyCode = currencyCode
    numberFormatter.locale = locale

    if let formattedAmount = numberFormatter.string(from: NSNumber(value: amount)) {
        return formattedAmount
    }

    // If NumberFormatter fails, use a consistent fallback
    return "\(currency) \(String(format: "%.2f", amount))"
}

/// Maps currency symbols or codes to proper ISO currency codes
private func mapCurrencyToCode(_ currencyInput: String) -> String {
    switch currencyInput.uppercased() {
    case "$", "USD":
        return "USD"
    case "€", "EUR":
        return "EUR"
    case "£", "GBP":
        return "GBP"
    case "¥", "JPY":
        return "JPY"
    case "SEK", "KR":
        return "SEK"
    case "NOK":
        return "NOK"
    case "DKK":
        return "DKK"
    default:
        // Default to SEK if currency is unrecognized
        return "SEK"
    }
}

/// Returns the appropriate locale for currency formatting
private func getLocaleForCurrency(_ currencyCode: String) -> Locale {
    switch currencyCode {
    case "USD":
        return Locale(identifier: "en_US")
    case "EUR":
        return Locale(identifier: "de_DE") // German formatting for EUR (6,51 €)
    case "GBP":
        return Locale(identifier: "en_GB")
    case "JPY":
        return Locale(identifier: "ja_JP")
    case "SEK":
        return Locale(identifier: "sv_SE")
    case "NOK":
        return Locale(identifier: "nb_NO")
    case "DKK":
        return Locale(identifier: "da_DK")
    default:
        // Default to Swedish locale for unknown currencies
        return Locale(identifier: "sv_SE")
    }
}

#Preview {
    VStack(spacing: 16) {
        RetailDetailedInvoiceItemsView(
            detailInvoice: FoodDeliveryDetail(
                invoiceID: "test_invoice",
                deliveryFee: 29.0,
                items: [
                    FoodDeliveryDetail.FoodItem(
                        name: "Margherita Pizza",
                        description: "Classic tomato and mozzarella",
                        price: 149.0,
                        quantity: 1.0
                    ),
                    FoodDeliveryDetail.FoodItem(
                        name: "Coca Cola",
                        description: "330ml can",
                        price: 25.0,
                        quantity: 2.0
                    )
                ],
                discount: 10.0
            ),
            subType: .foodDelivery,
            baseCurrency: "SEK"
        )

        RetailDetailedInvoiceSummaryView(
            detailInvoice: FoodDeliveryDetail(
                invoiceID: "test_invoice",
                deliveryFee: 29.0,
                items: [
                    FoodDeliveryDetail.FoodItem(
                        name: "Margherita Pizza",
                        description: "Classic tomato and mozzarella",
                        price: 149.0,
                        quantity: 1.0
                    ),
                    FoodDeliveryDetail.FoodItem(
                        name: "Coca Cola",
                        description: "330ml can",
                        price: 25.0,
                        quantity: 2.0
                    )
                ],
                discount: 10.0
            ),
            subType: .foodDelivery,
            baseCurrency: "SEK"
        )
    }
    .padding()
}
