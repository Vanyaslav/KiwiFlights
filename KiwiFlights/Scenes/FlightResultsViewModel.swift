//
//  FlightResultsViewModel.swift
//  KiwiFlights
//
//  Created by Tomas Baculák on 01/08/2023.
//

import Combine

class FlightResultsViewModel: ObservableObject {
    // in
    let dropFlightsList = PassthroughSubject<Void, Never>()
    let assignPrefferedFlight = PassthroughSubject<FlightsResponse.Itinerary, Never>()
    // out
    @Published var list: [FlightsResponse.Itinerary] = []
}
