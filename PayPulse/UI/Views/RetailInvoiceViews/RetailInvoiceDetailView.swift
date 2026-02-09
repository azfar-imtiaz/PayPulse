//
//  RetailInvoiceDetailView.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-02-08.
//

import SwiftUI
import Toasts

struct RetailInvoiceDetailView: View {
    let invoice: RetailInvoiceBase
    let subType: RetailInvoiceSubType

    @State private var detailInvoice: (any RetailInvoiceDetail)?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showToast = false
    @State private var toastMessage = ""

    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentToast) var presentToast
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var authManager: AuthManager

    private var invoiceService: InvoiceService {
        InvoiceService(apiClient: PayPulseAPIClient(authManager: authManager))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // Invoice ID section
                VStack(alignment: .leading, spacing: 0) {
                    Text("Invoice ID")
                        .font(.bodyLarge)
                        .foregroundStyle(Color.secondaryDarkGray)

                    Text(invoice.invoiceID)
                        .font(.bodyStandard)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .foregroundStyle(.gray)
                }
                .padding(.horizontal)

                // Base Invoice Details section
                Text("Invoice Details")
                    .font(.bodyLarge)
                    .foregroundStyle(Color.secondaryDarkGray)
                    .padding(.horizontal)

                RetailBaseInvoiceDetailsView(
                    invoice: invoice,
                    subType: subType,
                    showToast: $showToast,
                    toastMessage: $toastMessage
                )
                .padding(.horizontal)

                if let detailInvoice = detailInvoice {
                    // Only show first section for non-subscription invoices
                    if subType != .subscriptions {
                        Text(getFirstSectionTitle(for: subType))
                            .font(.bodyLarge)
                            .foregroundStyle(Color.secondaryDarkGray)
                            .padding(.horizontal)

                        RetailDetailedInvoiceItemsView(
                            detailInvoice: detailInvoice,
                            subType: subType,
                            baseCurrency: invoice.displayCurrency
                        )
                        .padding(.horizontal)
                    }

                    // Show passenger information section for travel invoices
                    if subType == .travel {
                        Text("Passenger Information")
                            .font(.bodyLarge)
                            .foregroundStyle(Color.secondaryDarkGray)
                            .padding(.horizontal)

                        RetailDetailedInvoicePassengerView(
                            detailInvoice: detailInvoice,
                            subType: subType
                        )
                        .padding(.horizontal)
                    }

                    Text(getSecondSectionTitle(for: subType))
                        .font(.bodyLarge)
                        .foregroundStyle(Color.secondaryDarkGray)
                        .padding(.horizontal)

                    RetailDetailedInvoiceSummaryView(
                        detailInvoice: detailInvoice,
                        subType: subType,
                        baseCurrency: invoice.displayCurrency
                    )
                    .padding(.horizontal)
                } else if isLoading {
                    // Loading indicator for detailed fields
                    ProgressView("Loading details...")
                        .padding()
                } else if let errorMessage = errorMessage {
                    // Error state for detailed fields
                    Text("Could not load additional details: \(errorMessage)")
                        .font(.bodyStandard)
                        .foregroundStyle(Color.accentDeepRed)
                        .padding()
                }

                Spacer(minLength: 100) // Ensure content doesn't get cut off
            }
            .padding(.top)
        }
        .onChange(of: showToast) { _, newValue in
            if newValue {
                let toast = ToastValue(icon: Image("copy"), message: toastMessage)
                presentToast(toast)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    showToast = false
                }
            }
        }
        .background(Color.primaryOffWhite)
        .navigationTitle("Invoice Details")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Icon(name: getIconNameColored(iconName: "circle-arrow-left"))
                }
            }
        }
        .onAppear {
            loadDetailedInvoice()
        }
    }

    private func loadDetailedInvoice() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                switch subType {
                case .foodDelivery:
                    let detail = try await invoiceService.getFoodDeliveryDetail(invoiceID: invoice.invoiceID)
                    await MainActor.run {
                        self.detailInvoice = detail
                        self.isLoading = false
                    }
                case .miscellaneous:
                    let detail = try await invoiceService.getMiscellaneousDetail(invoiceID: invoice.invoiceID)
                    await MainActor.run {
                        self.detailInvoice = detail
                        self.isLoading = false
                    }
                case .subscriptions:
                    let detail = try await invoiceService.getSubscriptionDetail(invoiceID: invoice.invoiceID)
                    await MainActor.run {
                        self.detailInvoice = detail
                        self.isLoading = false
                    }
                case .clothing:
                    let detail = try await invoiceService.getClothingDetail(invoiceID: invoice.invoiceID)
                    await MainActor.run {
                        self.detailInvoice = detail
                        self.isLoading = false
                    }
                case .travel:
                    let detail = try await invoiceService.getTravelDetail(invoiceID: invoice.invoiceID)
                    await MainActor.run {
                        self.detailInvoice = detail
                        self.isLoading = false
                    }
                case .technology:
                    let detail = try await invoiceService.getTechnologyDetail(invoiceID: invoice.invoiceID)
                    await MainActor.run {
                        self.detailInvoice = detail
                        self.isLoading = false
                    }
                default:
                    // For other sub-types, we don't have detail implementations yet
                    await MainActor.run {
                        self.detailInvoice = nil
                        self.isLoading = false
                        // Don't show error for unimplemented details, just show base invoice
                    }
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }

    private func getIconNameColored(iconName: String) -> String {
        if colorScheme == .dark {
            return "\(iconName)-light"
        } else {
            return "\(iconName)-dark"
        }
    }

    /// Returns the title for the first detail section based on invoice sub-type
    private func getFirstSectionTitle(for subType: RetailInvoiceSubType) -> String {
        switch subType {
        case .travel:
            return "Travel Details"
        default:
            return "Order Items"
        }
    }

    /// Returns the title for the second detail section based on invoice sub-type
    private func getSecondSectionTitle(for subType: RetailInvoiceSubType) -> String {
        switch subType {
        case .travel:
            return "Additional Details"
        default:
            return "Payment Details"
        }
    }
}

#Preview {
    NavigationStack {
        RetailInvoiceDetailView(
            invoice: RetailInvoiceBase(
                invoiceID: "retail_invoice_123",
                invoiceDate: "2025-02-05",
                totalAmount: 99.99,
                currency: "SEK",
                vendorName: "Test Vendor"
            ),
            subType: .technology
        )
    }
    .environmentObject(AuthManager.shared)
}
