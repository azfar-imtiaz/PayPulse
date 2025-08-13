//
//  InvoicesView.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-01-04.
//

import SwiftUI
import Toasts

enum TabTitles: String {
    case invoices
    case graphs
}

struct RentalLandingPage: View {
    let invoiceService             : InvoiceService
    @StateObject var viewModel     : InvoicesViewModel
    @State private var selectedTab : TabTitles = .invoices
    @State var selectedYear        : Int = Utils.getCurrentYear()
    @State var showSpinner         : Bool = false
    @State var loadingText         : String = ""
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentToast) var presentToast
    @Environment(\.colorScheme) private var colorScheme
    
    init(invoiceService: InvoiceService) {
        _viewModel = StateObject(wrappedValue: InvoicesViewModel(invoiceService: invoiceService))
        self.invoiceService = invoiceService
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .center) {
                TabView(selection: $selectedTab) {
                    if viewModel.invoicesHaveLoaded {
                        RentalListView(
                            viewModel: viewModel,
                            selectedYear: $selectedYear,
                            showSpinner: $showSpinner
                        ) {
                            ingestInvoicesWithPolling()
                        }
                            .tabItem {
                                Label("Invoices", systemImage: "list.bullet.rectangle.portrait.fill")
                            }
                            .tag(TabTitles.invoices)
                        
                        // the charts view shouldn't be displayed unless some invoices have been loaded
                        if viewModel.invoices.count > 0 {
                            RentalChartView(viewModel: viewModel)
                                .background(Color.primaryOffWhite)
                                .tabItem {
                                    Label("Charts", systemImage: "chart.xyaxis.line")
                                }
                                .tag(TabTitles.graphs)
                        }
                    }
                }
                .onAppear {
                    loadingText = "Loading invoices..."
                    loadInvoices(isReload: false)
                }
                
                LoadingDotsView(isLoading: $showSpinner, loadingText: loadingText)
            }
        }
        .navigationBarBackButtonHidden()
        .onChange(of: viewModel.reloadInvoices) { _, newValue in
            if newValue {
                loadingText = "Reloading invoices..."
                loadInvoices(isReload: true)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    getIconColored(iconName: "circle-arrow-left")
                }
                .disabled(showSpinner)
            }
            
            ToolbarItem(placement: .principal) {
                Text(selectedTab.rawValue.capitalized)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(
                        computeToolbarTextColor()
                    )
            }
            
            if selectedTab == .invoices {
                if viewModel.invoices.count > 0 {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            ingestLatestInvoice()
                        } label: {
                            getIconColored(iconName: "refresh-ccw-dot")
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
            } catch {
                // TODO: Handle errors here
                print("Error!")
                /*
                await MainActor.run { // Ensure UI updates for error are on main thread
                    viewModel.errorMessage = "Failed to load invoices: \(error.localizedDescription)"
                    viewModel.invoices = [] // Clear any partial data
                }
                 */
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
                
                // TODO: Throw error here
                print("Could not load invoices!")
            } catch {
                // TODO: Handle errors here
                print("Error!")
                let toastValue = ToastValue(
                    icon: Icon(name: "circle-x"),
                    message: viewModel.errorMessage ?? "Could not ingest invoices"
                )
                presentToast(toastValue)
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
            } catch {
                print("Error ingesting invoice!")
            }
        }
    }
    
    private func computeToolbarTextColor() -> Color {
        if selectedTab == .graphs {
            switch colorScheme {
            case .dark:
                return Color.secondaryDarkGray
            case .light:
                return Color.secondaryDarkGray
            @unknown default:
                return Color.primaryOffWhite
            }
        } else {
            if viewModel.invoices.count > 0 {
                return Color.primaryOffWhite
            } else {
                return Color.secondaryDarkGray
            }
        }
    }
    
    private func getIconColored(iconName: String) -> Image {
        if selectedTab == .graphs {
            switch colorScheme {
            case .dark:
                return Image("\(iconName)-light")
            case .light:
                return Image("\(iconName)-dark")
            @unknown default:
                return Image("\(iconName)-light")
            }
        } else {
            if colorScheme == .dark {
                return viewModel.invoices.count > 0 ? Image("\(iconName)-dark") : Image("\(iconName)-light")
            } else {
                return viewModel.invoices.count > 0 ? Image("\(iconName)-light") : Image("\(iconName)-dark")
            }
        }
    }
}

#Preview {
    RentalLandingPage(invoiceService: InvoiceService(apiClient: PayPulseAPIClient(authManager: AuthManager.shared)))
}
