//
//  FlightSearchViewModel.swift
//  KiwiFlights
//
//  Created by Tomas Baculák on 22/07/2023.
//

import Combine
import CombineExt
import Foundation


class FlightSearchViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    // in
    let confirm = PassthroughSubject<Void, Never>()
    let selectedDestinationId = PassthroughSubject<String, Never>()
    let selectedDepartureId = PassthroughSubject<String, Never>()
    
    @Published var departure: String = ""
    @Published var destination: String = ""
    // out
    @Published private var selectedDestination: PlaceResponse.Node?
    @Published private var selectedDeparture: PlaceResponse.Node?
    
    @Published var showError: String?
    @Published var airportList: [PlaceResponse.Node] = []
    @Published var flightsList: [FlightsResponse.Itinerary] = []
    
    @Published var prefferedFlight: FlightsResponse.Itinerary?
    
    @Published var isConfirmButtonEnabled: Bool = false
    @Published var isDestinationActive: Bool = false
    @Published var isDepartureActive: Bool = false
    
    @Published var isFlightResultsPresented: Bool = false
    
    init(service: DataProtocol = DataService()) {
        let departureEntry = $departure.dropFirst()
        let destinationEntry = $destination.dropFirst()
        
        let placesResult = Publishers.Merge(
            departureEntry,
            destinationEntry
        )
            .throttle(for: 1.5, scheduler: RunLoop.main, latest: true)
            .flatMapLatest { service.retrievePlaces(query: .init(searchString: $0)).materialize() }
            .share()
        
        placesResult.values()
            .map { $0.data.places.edges.map { $0.node } }
            .print()
            .assign(to: &$airportList)
        
        // manage departure
        departureEntry
            .map { _ in true }
            .assign(to: &$isDepartureActive)
        
        departureEntry
            .map { _ in false }
            .assign(to: &$isDestinationActive)
        
        let assignedDeparture = selectedDepartureId
            .map { id in
                self.airportList.first { $0.id == id }
            }
        
        assignedDeparture
            .compactMap { $0?.name }
            .assign(to: &$departure)
        
        assignedDeparture
            .compactMap { $0 }
            .assign(to: &$selectedDeparture)
        
        assignedDeparture
            .delay(for: 0.2, scheduler: RunLoop.main)
            .map { _ in false }
            .assign(to: &$isDepartureActive)
        
        // manage destination
        destinationEntry
            .map { _ in true }
            .assign(to: &$isDestinationActive)
        
        destinationEntry
            .map { _ in false }
            .assign(to: &$isDepartureActive)
        
        let assignedDestination = selectedDestinationId
            .map { id in
                self.airportList.first { $0.id == id }
            }
        
        assignedDestination
            .compactMap { $0?.name }
            .assign(to: &$destination)
        
        assignedDestination
            .compactMap { $0 }
            .assign(to: &$selectedDestination)
        
        assignedDestination
            .delay(for: 0.2, scheduler: RunLoop.main)
            .map { _ in false }
            .assign(to: &$isDestinationActive)
        
        //
        Publishers.CombineLatest(
            $selectedDeparture,
            $selectedDestination
        )
            .filter { $0.0 != nil && $0.1 != nil }
            .map { _ in true }
            .assign(to: &$isConfirmButtonEnabled)
        
        let flightsResult = confirm
            .flatMapLatest { service.retrieveFlights(query: .init()).materialize() }
        
        flightsResult.values()
            .compactMap { $0.data.onewayItineraries?.itineraries }
            // .map { $0.flatMap { $0.bookingOptions?.edges.map { $0.node } ?? [] } }
            .assign(to: &$flightsList)
        
        $flightsList.dropFirst().map {_ in true }.assign(to: &$isFlightResultsPresented)
        
        Publishers.Merge(
            placesResult.failures(),
            flightsResult.failures()
        )
            .map { $0.localizedDescription }
            .assign(to: &$showError)
    }
}

extension FlightSearchViewModel {
    struct FlightData {
        let price: Decimal
        let duration: String
    }
}
