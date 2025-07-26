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
                    
                    RentalListView(viewModel: viewModel, selectedYear: $selectedYear)
                        .tabItem {
                            Label("Invoices", systemImage: "list.bullet.rectangle.portrait.fill")
                        }
                        .tag(TabTitles.invoices)
                    
                    RentalChartView(viewModel: viewModel)
                        .background(Color.primaryOffWhite)
                        .tabItem {
                            Label("Charts", systemImage: "chart.xyaxis.line")
                        }
                        .tag(TabTitles.graphs)
                }
                .onAppear {
                    loadingText = "Loading invoices..."
                    loadInvoices()
                }
                
                LoadingDotsView(isLoading: $showSpinner, loadingText: loadingText)
            }
        }
        .navigationBarBackButtonHidden()
        .onChange(of: viewModel.reloadInvoices) { _, newValue in
            if newValue {
                loadingText = "Reloading invoices..."
                loadInvoices()
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    getIconColored(iconName: "circle-arrow-left")
                }
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
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        ingestLatestInvoice()
                    } label: {
                        getIconColored(iconName: "refresh-ccw-dot")
                    }
                }
            }
        }
    }
    
    private func loadInvoices() {
        showSpinner = true
        
        Task {
            defer {
                showSpinner = false
            }
            
            do {
                try await viewModel.getInvoices()
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
    
    private func ingestLatestInvoice() {
        showSpinner = true
        loadingText = "Fetching latest invoice..."
        
        Task {
            defer {
                showSpinner = false
            }
            
            do {
                let ingestionStatus = try await viewModel.ingestLatestInvoice()
                let toastValue: ToastValue
                if ingestionStatus {
                    toastValue = ToastValue(icon: Icon(name: "circle-check"), message: viewModel.successMessage ?? "Latest invoice ingested successfully!")
                } else {
                    toastValue = ToastValue(icon: Icon(name: "circle-x"), message: viewModel.errorMessage ?? "Error ingesting latest invoice.")
                }
                presentToast(toastValue)
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
            return Color.primaryOffWhite
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
                return Image("\(iconName)-dark")
            } else {
                return Image("\(iconName)-light")
            }
        }
    }
}

#Preview {
    RentalLandingPage(invoiceService: InvoiceService(apiClient: PayPulseAPIClient(authManager: AuthManager.shared)))
}
