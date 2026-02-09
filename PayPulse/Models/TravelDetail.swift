//
//  TravelDetail.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-02-09.
//

import Foundation

struct TravelDetail: RetailInvoiceDetail, Hashable {
    let invoiceID: String
    let travelDetails: [TravelSegment]
    let transportType: String
    let transportCompany: String?
    let bookingReference: String
    let passengers: [Passenger]

    enum CodingKeys: String, CodingKey {
        case invoiceID = "InvoiceID"
        case travelDetails = "travel_details"
        case transportType = "transport_type"
        case transportCompany = "transport_company"
        case bookingReference = "booking_reference"
        case passengers
    }

    // MARK: - Travel Segment

    struct TravelSegment: Codable, Hashable {
        let arrivalLocation: String
        let arrivalDate: String?
        let departureLocation: String
        let departureDate: String?

        enum CodingKeys: String, CodingKey {
            case arrivalLocation = "arrival_location"
            case arrivalDate = "arrival_date"
            case departureLocation = "departure_location"
            case departureDate = "departure_date"
        }

        /// Returns formatted departure date or "Not specified" if nil
        func getFormattedDepartureDate() -> String {
            guard let departureDate = departureDate else { return "Not specified" }
            return formatTravelDate(departureDate)
        }

        /// Returns formatted arrival date or "Not specified" if nil
        func getFormattedArrivalDate() -> String {
            guard let arrivalDate = arrivalDate else { return "Not specified" }
            return formatTravelDate(arrivalDate)
        }

        /// Formats various date formats found in travel invoices
        private func formatTravelDate(_ dateString: String) -> String {
            // Handle ISO format: "2025-07-31T16:25:00"
            if let isoDate = ISO8601DateFormatter().date(from: dateString) {
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM d, yyyy HH:mm"
                return formatter.string(from: isoDate)
            }

            // Handle simple date format: "2021-05-26"
            let simpleDateFormatter = DateFormatter()
            simpleDateFormatter.dateFormat = "yyyy-MM-dd"
            if let simpleDate = simpleDateFormatter.date(from: dateString) {
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM d, yyyy"
                return formatter.string(from: simpleDate)
            }

            // Handle custom format: "20.06.2022 12:35"
            let customFormatter = DateFormatter()
            customFormatter.dateFormat = "dd.MM.yyyy HH:mm"
            if let customDate = customFormatter.date(from: dateString) {
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM d, yyyy HH:mm"
                return formatter.string(from: customDate)
            }

            // Handle readable format: "19 December 2025 Friday"
            let readableFormatter = DateFormatter()
            readableFormatter.dateFormat = "d MMMM yyyy EEEE"
            readableFormatter.locale = Locale(identifier: "en_US")
            if let readableDate = readableFormatter.date(from: dateString) {
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM d, yyyy"
                return formatter.string(from: readableDate)
            }

            // If no format matches, return as-is
            return dateString
        }
    }

    // MARK: - Passenger

    struct Passenger: Codable, Hashable {
        let name: String
    }

    // MARK: - Computed Properties

    /// Returns formatted transport type with capitalization
    func getFormattedTransportType() -> String {
        return transportType.capitalized
    }

    /// Returns the number of travel segments
    func getSegmentCount() -> Int {
        return travelDetails.count
    }

    /// Returns the number of passengers
    func getPassengerCount() -> Int {
        return passengers.count
    }

    /// Returns formatted transport company or "Not specified" if nil
    func getFormattedTransportCompany() -> String {
        return transportCompany ?? "Not specified"
    }
}