//
//  RentalLandingPage.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-01-04.
//

import SwiftUI
import Toasts

struct RentalLandingPage: View {
    let invoiceService             : InvoiceService
    @ObservedObject var viewModel  : RentalInvoicesViewModel
    @State var selectedYear        : Int = Utils.getCurrentYear()
    @State var showSpinner         : Bool = false
    @State var loadingText         : String = ""

    @Environment(\.presentToast) var presentToast
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var authManager: AuthManager

    init(invoiceService: InvoiceService, viewModel: RentalInvoicesViewModel) {
        self.invoiceService = invoiceService
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .center) {
                VStack(spacing: 0) {
                    if viewModel.invoicesHaveLoaded {
                        RentalListView(
                            viewModel: viewModel,
                            selectedYear: $selectedYear,
                            showSpinner: $showSpinner,
                            refreshAction: {
                                ingestLatestInvoice()
                            }
                        ) {
                            ingestInvoicesWithPolling()
                        }
                    }
                    Spacer(minLength: 0)
                }
                .background(Color.primarySurface)
                .onAppear {
                    loadingText = "Loading invoices..."
                    if !viewModel.invoicesHaveLoaded {
                        loadInvoices(isReload: false)
                    }
                }

                LoadingDotsView(isLoading: $showSpinner, loadingText: loadingText)
            }
            .onChange(of: viewModel.reloadInvoices) { _, newValue in
                if newValue {
                    loadingText = "Reloading invoices..."
                    loadInvoices(isReload: true)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    NavTitle(text: "Rental")
                }

                if viewModel.invoices.count > 0 {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            ingestLatestInvoice()
                        } label: {
                            Utils.getIconColored(colorScheme: colorScheme, iconName: "refresh-ccw-dot")
                        }
                        .disabled(showSpinner)
                    }
                }
            }
        }
    }

    private func loadInvoices(isReload: Bool) {
        showSpinner = true
        viewModel.invoicesHaveLoaded = false
        
        Task {
            defer {
                showSpinner = false
                viewModel.invoicesHaveLoaded = true
            }
            
            do {
                if isReload {
                    try await Task.sleep(nanoseconds: 3_000_000_000)
                }
                try await viewModel.getInvoices()
                if isReload {
                    let toastValue = ToastValue(icon: Icon(name: "circle-check"), message: viewModel.successMessage ?? "Latest invoice ingested successfully!")
                    presentToast(toastValue)
                }
            } catch let apiError as APIError {
                Utils.handleAPITokenExpiration(apiError, authManager: authManager) {
                    let errorToast = ToastValue(
                        icon: Icon(name: "circle-x"),
                        message: "Failed to load invoices: \(viewModel.errorMessage ?? apiError.errorDescription ?? apiError.localizedDescription)"
                    )
                    presentToast(errorToast)
                }
            }
        }
    }
    
    private func ingestInvoicesWithPolling() {
        showSpinner = true
        viewModel.invoicesHaveLoaded = false
        
        let maxAttempts = 5
        let delayInSeconds = 2
        
        Task {
            defer {
                showSpinner = false
                viewModel.invoicesHaveLoaded = true
            }
            
            do {
                loadingText = "Ingesting invoices..."
                try await viewModel.ingestInvoices()
                
                loadingText = "Loading invoices..."
                for _ in 0..<maxAttempts {
                    try await viewModel.getInvoices()
                    if viewModel.invoices.count > 0 {
                        print("Invoices have loaded!")
                        return
                    }
                    
                    try? await Task.sleep(nanoseconds: UInt64(delayInSeconds) * 1_000_000_000)
                            print("No invoices found yet. Trying again...")
                }
                
                print("Could not load invoices!")
                let errorToast = ToastValue(
                    icon: Icon(name: "circle-x"),
                    message: "Failed to load invoices."
                )
                presentToast(errorToast)
            } catch let apiError as APIError {
                Utils.handleAPITokenExpiration(apiError, authManager: authManager) {
                    let errorToast = ToastValue(
                        icon: Icon(name: "circle-x"),
                        message: "Failed to load invoices: \(viewModel.errorMessage ?? apiError.errorDescription ?? apiError.localizedDescription)"
                    )
                    presentToast(errorToast)
                }
            }
        }
    }
    
    private func ingestLatestInvoice() {
        showSpinner = true
        viewModel.invoicesHaveLoaded = false
        loadingText = "Fetching latest invoice..."
        
        Task {
            defer {
                showSpinner = false
                viewModel.invoicesHaveLoaded = true
            }
            
            do {
                let (displayToast, ingestionStatus) = try await viewModel.ingestLatestInvoice()
                let toastValue: ToastValue
                if displayToast {
                    if ingestionStatus {
                        toastValue = ToastValue(icon: Icon(name: "circle-check"), message: viewModel.successMessage ?? "Latest invoice ingested successfully!")
                    } else {
                        toastValue = ToastValue(icon: Icon(name: "circle-x"), message: viewModel.errorMessage ?? "Error ingesting latest invoice.")
                    }
                    presentToast(toastValue)
                } else {
                    viewModel.reloadInvoices = true
                }
            } catch let apiError as APIError {
                Utils.handleAPITokenExpiration(apiError, authManager: authManager) {
                    let errorToast = ToastValue(
                        icon: Icon(name: "circle-x"),
                        message: "Failure: \(viewModel.errorMessage ?? apiError.errorDescription ?? apiError.localizedDescription)"
                    )
                    presentToast(errorToast)
                }
            }
        }
    }
}

#Preview {
    let invoiceService = InvoiceService(apiClient: PayPulseAPIClient(authManager: AuthManager.shared))
    RentalLandingPage(
        invoiceService: invoiceService,
        viewModel: RentalInvoicesViewModel(invoiceService: invoiceService)
    )
}
