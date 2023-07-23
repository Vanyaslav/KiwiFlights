//
//  FlightsResponse.swift
//  KiwiFlights
//
//  Created by Tomas Baculák on 23/07/2023.
//

import Foundation

struct FlightsResponse: Decodable {
    let data: Data
}

extension FlightsResponse {
    struct Data: Decodable {
        let onewayItineraries: OnewayItineraries?
    }
    
    struct OnewayItineraries: Decodable {
        let itineraries: [Itinerary]?
    }
    
    struct Itinerary: Decodable, Identifiable {
        let id: String
        let duration: Int?
        let bookingOptions: BookingOptions?
        let sector: Sector?
    }
    
    struct BookingOptions: Decodable {
        let edges: [Nodes]
    }
    
    struct Nodes: Decodable {
        let node: Node
    }
    
    struct Node: Decodable {
        let price: Price?
    }
    
    struct Price: Decodable {
        let amount: String?
        let formattedValue: String?
    }
    
    struct Sector: Decodable {
        let sectorSegments: [Segments]
    }
    
    struct Segments: Decodable {
        let segment: Segment
    }
    
    struct Segment: Decodable {
        let source: FlightDetails
        let destination: FlightDetails
    }
    
    struct FlightDetails: Decodable {
        let station: AirportDetails
    }
    
    struct AirportDetails: Decodable {
        let city: City
    }
    
    struct City: Decodable {
        let name: String?
    }
}
