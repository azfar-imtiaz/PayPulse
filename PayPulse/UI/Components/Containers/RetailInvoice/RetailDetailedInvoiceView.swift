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
            case .clothing:
                if let clothingDetail = detailInvoice as? ClothingDetail {
                    ClothingItemsView(detail: clothingDetail, baseCurrency: baseCurrency)
                } else {
                    Text("Error: Could not display clothing details")
                        .font(.bodyStandard)
                        .foregroundStyle(Color.accentDeepRed)
                }
            case .travel:
                if let travelDetail = detailInvoice as? TravelDetail {
                    TravelItemsView(detail: travelDetail)
                } else {
                    Text("Error: Could not display travel details")
                        .font(.bodyStandard)
                        .foregroundStyle(Color.accentDeepRed)
                }
            case .technology:
                if let technologyDetail = detailInvoice as? TechnologyDetail {
                    TechnologyItemsView(detail: technologyDetail, baseCurrency: baseCurrency)
                } else {
                    Text("Error: Could not display technology details")
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
            case .subscriptions:
                if let subscriptionDetail = detailInvoice as? SubscriptionDetail {
                    SubscriptionItemsView(detail: subscriptionDetail)
                } else {
                    Text("Error: Could not display subscription details")
                        .font(.bodyStandard)
                        .foregroundStyle(Color.accentDeepRed)
                }
            case .clothing:
                if let clothingDetail = detailInvoice as? ClothingDetail {
                    ClothingSummaryView(detail: clothingDetail, baseCurrency: baseCurrency)
                } else {
                    Text("Error: Could not display clothing summary")
                        .font(.bodyStandard)
                        .foregroundStyle(Color.accentDeepRed)
                }
            case .travel:
                if let travelDetail = detailInvoice as? TravelDetail {
                    TravelSummaryView(detail: travelDetail)
                } else {
                    Text("Error: Could not display travel summary")
                        .font(.bodyStandard)
                        .foregroundStyle(Color.accentDeepRed)
                }
            case .technology:
                if let technologyDetail = detailInvoice as? TechnologyDetail {
                    TechnologySummaryView(detail: technologyDetail, baseCurrency: baseCurrency)
                } else {
                    Text("Error: Could not display technology summary")
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

                            Text(Utils.formatCurrency(item.getTotalPrice(), currency: baseCurrency))
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
                    value: Utils.formatCurrency(detail.getSubtotal(), currency: baseCurrency)
                )

                if detail.deliveryFee > 0 {
                    Divider()
                    KeyStringValueRow(
                        key: "Delivery Fee",
                        value: Utils.formatCurrency(detail.deliveryFee, currency: baseCurrency)
                    )
                }

                if detail.discount > 0 {
                    Divider()
                    KeyStringValueRow(
                        key: "Discount",
                        value: Utils.formatCurrency(-detail.discount, currency: baseCurrency)
                    )
                }

                Divider()
                KeyStringValueRow(
                    key: "Calculated Total",
                    value: Utils.formatCurrency(detail.getTotal(), currency: baseCurrency)
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

                                Text(Utils.formatCurrency(item.getTotalPrice(), currency: baseCurrency))
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

// MARK: - Retail Detailed Invoice Passenger View

struct RetailDetailedInvoicePassengerView: View {
    let detailInvoice: any RetailInvoiceDetail
    let subType: RetailInvoiceSubType

    var body: some View {
        Group {
            switch subType {
            case .travel:
                if let travelDetail = detailInvoice as? TravelDetail {
                    TravelPassengerView(detail: travelDetail)
                } else {
                    Text("Error: Could not display travel passenger information")
                        .font(.bodyStandard)
                        .foregroundStyle(Color.accentDeepRed)
                }
            default:
                // Other invoice types don't have passenger sections
                EmptyView()
            }
        }
    }
}

// MARK: - Technology Items View

private struct TechnologyItemsView: View {
    let detail: TechnologyDetail
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

                                Text(Utils.formatCurrency(item.getTotalPrice(), currency: baseCurrency))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }

            // Additional info section (if notes are present)
            if detail.description != nil || detail.notes != nil {
                InvoiceDetailsContainer {
                    VStack(alignment: .leading, spacing: 8) {
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

// MARK: - Technology Summary View

private struct TechnologySummaryView: View {
    let detail: TechnologyDetail
    let baseCurrency: String

    var body: some View {
        InvoiceDetailsContainer {
            VStack(spacing: 8) {
                KeyStringValueRow(
                    key: "Subtotal",
                    value: Utils.formatCurrency(detail.getSubtotal(), currency: baseCurrency)
                )

                if detail.deliveryFee > 0 {
                    Divider()
                    KeyStringValueRow(
                        key: "Delivery Fee",
                        value: Utils.formatCurrency(detail.deliveryFee, currency: baseCurrency)
                    )
                }

                if detail.tax > 0 {
                    Divider()
                    KeyStringValueRow(
                        key: "Tax",
                        value: Utils.formatCurrency(detail.tax, currency: baseCurrency)
                    )
                }

                if detail.paymentMethod != nil {
                    Divider()
                    KeyStringValueRow(
                        key: "Payment Method",
                        value: detail.getFormattedPaymentMethod()
                    )
                }

                Divider()
                KeyStringValueRow(
                    key: "Calculated Total",
                    value: Utils.formatCurrency(detail.getTotal(), currency: baseCurrency)
                )
            }
        }
    }
}

// MARK: - Travel Items View

private struct TravelItemsView: View {
    let detail: TravelDetail

    var body: some View {
        InvoiceDetailsContainer {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(detail.travelDetails.indices, id: \.self) { index in
                    let segment = detail.travelDetails[index]

                    if index > 0 {
                        Divider()
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Leg \(index + 1)")
                                .font(.bodyStandard)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            Spacer()
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("From:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(segment.departureLocation)
                                    .font(.bodyStandard)
                                    .foregroundColor(.primary)
                                Spacer()
                            }

                            HStack {
                                Text("To:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(segment.arrivalLocation)
                                    .font(.bodyStandard)
                                    .foregroundColor(.primary)
                                Spacer()
                            }

                            if segment.departureDate != nil {
                                HStack {
                                    Text("Departure:")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(segment.getFormattedDepartureDate())
                                        .font(.caption)
                                        .foregroundColor(.primary)
                                    Spacer()
                                }
                            }

                            if segment.arrivalDate != nil {
                                HStack {
                                    Text("Arrival:")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(segment.getFormattedArrivalDate())
                                        .font(.caption)
                                        .foregroundColor(.primary)
                                    Spacer()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Travel Passenger View

private struct TravelPassengerView: View {
    let detail: TravelDetail

    var body: some View {
        InvoiceDetailsContainer {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(detail.passengers.indices, id: \.self) { index in
                    let passenger = detail.passengers[index]

                    if index > 0 {
                        Divider()
                    }

                    HStack {
                        Text(passenger.name)
                            .font(.bodyStandard)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                }
            }
        }
    }
}

// MARK: - Travel Summary View

private struct TravelSummaryView: View {
    let detail: TravelDetail

    var body: some View {
        InvoiceDetailsContainer {
            VStack(spacing: 8) {
                KeyStringValueRow(
                    key: "Transport Type",
                    value: detail.getFormattedTransportType()
                )

                Divider()
                KeyStringValueRow(
                    key: "Company",
                    value: detail.getFormattedTransportCompany()
                )

                Divider()
                KeyStringValueRow(
                    key: "Booking Reference",
                    value: detail.bookingReference
                )

                Divider()
                KeyStringValueRow(
                    key: "Travel Legs",
                    value: "\(detail.getSegmentCount())"
                )

                Divider()
                KeyStringValueRow(
                    key: "Passengers",
                    value: "\(detail.getPassengerCount())"
                )
            }
        }
    }
}

// MARK: - Clothing Items View

private struct ClothingItemsView: View {
    let detail: ClothingDetail
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

                            Text(item.brand)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            Text(item.getFormattedPrice())
                                .font(.bodyStandard)
                                .foregroundColor(.primary)

                            Text(Utils.formatCurrency(item.getTotalPrice(), currency: baseCurrency))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Clothing Summary View

private struct ClothingSummaryView: View {
    let detail: ClothingDetail
    let baseCurrency: String

    var body: some View {
        InvoiceDetailsContainer {
            VStack(spacing: 8) {
                KeyStringValueRow(
                    key: "Subtotal",
                    value: Utils.formatCurrency(detail.getSubtotal(), currency: baseCurrency)
                )

                if detail.deliveryFee > 0 {
                    Divider()
                    KeyStringValueRow(
                        key: "Delivery Fee",
                        value: Utils.formatCurrency(detail.deliveryFee, currency: baseCurrency)
                    )
                }

                if detail.tax > 0 {
                    Divider()
                    KeyStringValueRow(
                        key: "Tax",
                        value: Utils.formatCurrency(detail.tax, currency: baseCurrency)
                    )
                }

                if detail.paymentMethod != nil {
                    Divider()
                    KeyStringValueRow(
                        key: "Payment Method",
                        value: detail.getFormattedPaymentMethod()
                    )
                }

                Divider()
                KeyStringValueRow(
                    key: "Calculated Total",
                    value: Utils.formatCurrency(detail.getTotal(), currency: baseCurrency)
                )
            }
        }
    }
}

// MARK: - Subscription Items View

private struct SubscriptionItemsView: View {
    let detail: SubscriptionDetail

    var body: some View {
        InvoiceDetailsContainer {
            VStack(alignment: .leading, spacing: 8) {
                KeyStringValueRow(
                    key: "Payment Method",
                    value: detail.getFormattedPaymentMethod()
                )

                if detail.duration != nil {
                    Divider()
                    KeyStringValueRow(
                        key: "Duration",
                        value: detail.getFormattedDuration()
                    )
                }

                if detail.invoiceNumber != nil {
                    Divider()
                    KeyStringValueRow(
                        key: "Invoice Number",
                        value: detail.getFormattedInvoiceNumber()
                    )
                }

                if detail.receiptNumber != nil {
                    Divider()
                    KeyStringValueRow(
                        key: "Receipt Number",
                        value: detail.getFormattedReceiptNumber()
                    )
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
                    value: Utils.formatCurrency(detail.getSubtotal(), currency: baseCurrency)
                )

                if detail.deliveryFee > 0 {
                    Divider()
                    KeyStringValueRow(
                        key: "Delivery Fee",
                        value: Utils.formatCurrency(detail.deliveryFee, currency: baseCurrency)
                    )
                }

                if detail.tax > 0 {
                    Divider()
                    KeyStringValueRow(
                        key: "Tax",
                        value: Utils.formatCurrency(detail.tax, currency: baseCurrency)
                    )
                }

                Divider()
                KeyStringValueRow(
                    key: "Calculated Total",
                    value: Utils.formatCurrency(detail.getTotal(), currency: baseCurrency)
                )
            }
        }
    }
}


// MARK: - Helper Functions


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
