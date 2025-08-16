//
//  InvoicesViewModel.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-06-29.
//

import Foundation
import OrderedCollections

@MainActor
class InvoicesViewModel: ObservableObject {
    @Published var invoiceIngestionCount : InvoiceCountModel = InvoiceCountModel(invoiceCount: 0)
    @Published var invoices              : OrderedDictionary<Int, [InvoiceModel]> = [:]
    @Published var errorMessage          : String?
    @Published var successMessage        : String?
    @Published var reloadInvoices        : Bool = false
    @Published var invoicesHaveLoaded    : Bool = false
    
    private let invoiceService: InvoiceService
    
    init(invoiceService: InvoiceService) {
        self.invoiceService = invoiceService
    }
    
    func ingestInvoices() async {
        errorMessage = nil
        
        do {
            self.invoiceIngestionCount = try await invoiceService.ingestInvoices(type: "rental")
        } catch {
            self.errorMessage = (error as? APIError)?.localizedDescription ?? error.localizedDescription
            print("Failed to ingest invoices: \(self.errorMessage ?? "Unknown error")")
        }
    }
    
    func ingestLatestInvoice() async throws -> (displayToast: Bool, ingestionStatus: Bool) {
        successMessage = nil
        errorMessage = nil
        
        do {
            let responseCode = try await invoiceService.ingestLatestInvoice(type: "rental")
            if responseCode == 200 {
                self.successMessage = "This month's invoice already exists."
                return (displayToast: true, ingestionStatus: true)
            } else if responseCode == 201 {
                self.successMessage = "Invoice found and processed!"
                return (displayToast: false, ingestionStatus: true)
            } else if responseCode == 204 {
                self.successMessage = "Invoice not yet available."
                return (displayToast: true, ingestionStatus: true)
            }
        } catch {
            self.errorMessage = (error as? APIError)?.localizedDescription ?? error.localizedDescription
            print("Failed to ingest latest invoice: \(self.errorMessage ?? "Unknown error")")
        }
        return (displayToast: true, ingestionStatus: false)
    }
    
    func getInvoices() async throws {
        errorMessage = nil
        
        do {
            let data = try await invoiceService.getRentalInvoices(type: "rental")
            await MainActor.run {
                self.invoices = data
            }
        } catch {
            self.errorMessage = (error as? APIError)?.localizedDescription ?? error.localizedDescription
            print("Failed to get invoices: \(self.errorMessage ?? "Unknown error")")
        }
    }
    
    func getLatestInvoice(invoices: OrderedDictionary<Int, [InvoiceModel]>) -> InvoiceModel? {
        if let latestYear = invoices.keys.max() {
            return invoices[latestYear]?.first
        }
        return nil
    }
    
    func getFilteredData(for parameter: ParameterType, selectedYear: Int?) -> [(String, Int)] {
        // This function filters the invoices on year as well as on the following properties: baseRent, coldWater, hotWater, electricity, and totalRent
        
        if let year = selectedYear {
            // Single year view - return monthly data
            return getMonthlyData(for: parameter, year: year)
        } else {
            // All years view - return aggregated data
            return getAggregatedData(for: parameter)
        }
    }
    
    private func getMonthlyData(for parameter: ParameterType, year: Int) -> [(String, Int)] {
        var result: [(String, Int)] = []
        let yearInvoices = invoices[year] ?? []
        
        for invoice in yearInvoices {
            let key = invoice.getDueMonthName()
            result.append((key, getValue(for: parameter, from: invoice)))
        }
        
        return result.reversed()
    }
    
    private func getAggregatedData(for parameter: ParameterType) -> [(String, Int)] {
        let allInvoices = self.invoices.values.flatMap { $0 }
        
        // Determine aggregation level based on data span
        let years = Set(allInvoices.map { Int($0.dueDateYear) ?? 0 })
        let yearSpan = years.count
        
        if yearSpan > 5 {
            // Yearly aggregation for 5+ years
            return getYearlyAggregatedData(for: parameter, invoices: allInvoices)
        } else if yearSpan >= 1 {
            // Quarterly aggregation for 1-5 years
            return getQuarterlyAggregatedData(for: parameter, invoices: allInvoices)
        } else {
            // Fallback to monthly if less than 1 year of data
            var result: [(String, Int)] = []
            for invoice in allInvoices {
                result.append((invoice.dueDateYear, getValue(for: parameter, from: invoice)))
            }
            return result.reversed()
        }
    }
    
    private func getQuarterlyAggregatedData(for parameter: ParameterType, invoices: [InvoiceModel]) -> [(String, Int)] {
        var quarterlyData: [String: [Int]] = [:]
        var quarterOrder: [String] = []
        
        for invoice in invoices {
            let quarter = getQuarterFromInvoice(invoice)
            let quarterKey = "\(invoice.dueDateYear)-\(quarter)"
            
            if quarterlyData[quarterKey] == nil {
                quarterlyData[quarterKey] = []
                quarterOrder.append(quarterKey)
            }
            
            quarterlyData[quarterKey]?.append(getValue(for: parameter, from: invoice))
        }
        
        // Sort quarters chronologically
        quarterOrder.sort { first, second in
            let firstComponents = first.split(separator: "-")
            let secondComponents = second.split(separator: "-")
            
            let firstYear = Int(firstComponents[0]) ?? 0
            let secondYear = Int(secondComponents[0]) ?? 0
            
            if firstYear != secondYear {
                return firstYear < secondYear
            }
            
            let firstQuarter = firstComponents[1]
            let secondQuarter = secondComponents[1]
            return firstQuarter < secondQuarter
        }
        
        // Calculate averages and create result with year information
        var result: [(String, Int)] = []
        var previousYear: String? = nil
        
        for quarterKey in quarterOrder {
            if let values = quarterlyData[quarterKey], !values.isEmpty {
                let average = values.reduce(0, +) / values.count
                let components = quarterKey.split(separator: "-")
                let year = String(components[0])
                let quarter = String(components[1])
                
                // Include year in label for first quarter of each year
                let label: String
                if previousYear != year {
                    label = "\(year)-\(quarter)"
                    previousYear = year
                } else {
                    label = quarter
                }
                
                result.append((label, average))
            }
        }
        
        return result
    }
    
    private func getYearlyAggregatedData(for parameter: ParameterType, invoices: [InvoiceModel]) -> [(String, Int)] {
        var yearlyData: [String: [Int]] = [:]
        
        for invoice in invoices {
            let year = invoice.dueDateYear
            
            if yearlyData[year] == nil {
                yearlyData[year] = []
            }
            
            yearlyData[year]?.append(getValue(for: parameter, from: invoice))
        }
        
        // Sort years and calculate averages
        let sortedYears = yearlyData.keys.sorted { Int($0) ?? 0 < Int($1) ?? 0 }
        
        var result: [(String, Int)] = []
        for year in sortedYears {
            if let values = yearlyData[year], !values.isEmpty {
                let average = values.reduce(0, +) / values.count
                result.append((year, average))
            }
        }
        
        return result
    }
    
    private func getQuarterFromInvoice(_ invoice: InvoiceModel) -> String {
        // Extract month from invoice and determine quarter
        let monthName = invoice.getDueMonthName()
        let monthNumber = getMonthNumber(from: monthName)
        
        switch monthNumber {
        case 1...3:
            return "Q1"
        case 4...6:
            return "Q2"
        case 7...9:
            return "Q3"
        case 10...12:
            return "Q4"
        default:
            return "Q1"
        }
    }
    
    private func getMonthNumber(from monthName: String) -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        
        if let date = dateFormatter.date(from: monthName) {
            let calendar = Calendar.current
            return calendar.component(.month, from: date)
        }
        
        // Fallback mapping if date formatter fails
        let months = ["January": 1, "February": 2, "March": 3, "April": 4,
                     "May": 5, "June": 6, "July": 7, "August": 8,
                     "September": 9, "October": 10, "November": 11, "December": 12]
        
        return months[monthName] ?? 1
    }
    
    private func getValue(for parameter: ParameterType, from invoice: InvoiceModel) -> Int {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        switch parameter {
        case .baseRent:
            return invoice.hyra
        case .coldWater:
            return invoice.kallvatten
        case .hotWater:
            return invoice.varmvatten
        case .electricity:
            return invoice.el
        case .totalRent:
            return invoice.totalAmount
        }
    }
}
