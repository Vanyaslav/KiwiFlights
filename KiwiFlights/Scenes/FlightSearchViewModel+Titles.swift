//
//  FlightSearchViewModel+Titles.swift
//  KiwiFlights
//
//  Created by Tomas Baculák on 24/07/2023.
//

import Foundation

extension FlightSearchViewModel {
    var prefferedFlightURL: URL? {
        guard let id = preferredFlight?.legacyId
        else { return nil }
        return URL(string: "https://images.kiwi.com/photos/600x600/\(id).jpg")
    }
    
    var stopsCount: Int {
        guard let segments = preferredFlight?.sector?.sectorSegments
        else { return 0 }
        return segments.count - 1
    }
    
    var stopTitle: String {
        stopsCount == 1
             ? "\(stopsCount) stop"
             : "\(stopsCount) stops"
    }
    
    var departureCityName: String {
        preferredFlight?.departureCityName ?? ""
    }
    
    var destinationCityName: String {
        preferredFlight?.destinationCityName ?? ""
    }
    
    var flightPrice: String {
        preferredFlight?.flightPrice ?? ""
    }
    
    var durationTitle: String {
        preferredFlight?.duration?.hoursFormatFromSeconds ?? ""
    }
}
