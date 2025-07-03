//
//  InvoicesView.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-01-04.
//

import SwiftUI

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
    
    @Environment(\.dismiss) private var dismiss
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
                    loadInvoices()
                }
            }
            .blur(radius: showSpinner ? 3.0 : 0.0)
            
            if showSpinner {
                ProgressView()
                    .foregroundStyle(Color.accentDeepOrange)
                    .padding()
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left.circle")
                        .foregroundStyle(
                            computeToolbarTextColor()
                        )
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
}

#Preview {
    RentalLandingPage(invoiceService: InvoiceService(apiClient: PayPulseAPIClient(authManager: AuthManager.shared)))
}
