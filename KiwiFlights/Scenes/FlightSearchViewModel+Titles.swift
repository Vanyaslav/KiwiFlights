//
//  FlightSearchViewModel+Titles.swift
//  KiwiFlights
//
//  Created by Tomas Baculák on 24/07/2023.
//

import Foundation

extension FlightSearchViewModel {
    var prefferedFlightURL: URL? {
        guard let id = prefferedFlight?.legacyId
        else { return nil }
        return URL(string: "https://images.kiwi.com/photos/600x600/\(id).jpg")
    }
    
    var stopsCount: Int {
        guard let segments = prefferedFlight?.sector?.sectorSegments
        else { return 0 }
        return segments.count - 1
    }
    
    var stopTitle: String {
        stopsCount == 1
             ? "\(stopsCount) stop"
             : "\(stopsCount) stops"
    }
    
    var departureCityName: String {
        prefferedFlight?.departureCityName ?? ""
    }
    
    var destinationCityName: String {
        prefferedFlight?.destinationCityName ?? ""
    }
    
    var flightPrice: String {
        prefferedFlight?.flightPrice ?? ""
    }
    
    var durationTitle: String {
        prefferedFlight?.duration?.hoursFormatFromSeconds ?? ""
    }
}
