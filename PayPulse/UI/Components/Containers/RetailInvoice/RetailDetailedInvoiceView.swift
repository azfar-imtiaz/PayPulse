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

    var body: some View {
        Group {
            switch subType {
            case .foodDelivery:
                if let foodDeliveryDetail = detailInvoice as? FoodDeliveryDetail {
                    FoodDeliveryItemsView(detail: foodDeliveryDetail)
                } else {
                    Text("Error: Could not display food delivery details")
                        .foregroundColor(.red)
                }
            default:
                // For other sub-types that don't have detail implementations yet
                InvoiceDetailsContainer {
                    Text("Additional details not yet available for \(subType.displayName)")
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

    var body: some View {
        Group {
            switch subType {
            case .foodDelivery:
                if let foodDeliveryDetail = detailInvoice as? FoodDeliveryDetail {
                    FoodDeliverySummaryView(detail: foodDeliveryDetail)
                } else {
                    Text("Error: Could not display food delivery summary")
                        .foregroundColor(.red)
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

                            Text(String(format: "%.2f SEK", item.getTotalPrice()))
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

    var body: some View {
        InvoiceDetailsContainer {
            VStack(spacing: 8) {
                KeyStringValueRow(
                    key: "Subtotal",
                    value: String(format: "%.2f SEK", detail.getSubtotal())
                )

                if detail.deliveryFee > 0 {
                    Divider()
                    KeyStringValueRow(
                        key: "Delivery Fee",
                        value: String(format: "%.2f SEK", detail.deliveryFee)
                    )
                }

                if detail.discount > 0 {
                    Divider()
                    KeyStringValueRow(
                        key: "Discount",
                        value: String(format: "-%.2f SEK", detail.discount)
                    )
                }

                Divider()
                KeyStringValueRow(
                    key: "Calculated Total",
                    value: String(format: "%.2f SEK", detail.getTotal())
                )
            }
        }
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
            subType: .foodDelivery
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
            subType: .foodDelivery
        )
    }
    .padding()
}
