//
//  FlightSearchViewModel.swift
//  KiwiFlights
//
//  Created by Tomas Baculák on 22/07/2023.
//

import Combine
import CombineExt
import Foundation
import OrderedCollections


class FlightSearchViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    private var storage: LocalStorage
    let page: Int
    // in
    let confirm = PassthroughSubject<Void, Never>()
    let selectedDestinationId = PassthroughSubject<String, Never>()
    let selectedDepartureId = PassthroughSubject<String, Never>()
    
    @Published var departure: String = ""
    @Published var destination: String = ""
    // out
    @Published private var selectedDestination: PlaceResponse.Node?
    @Published private var selectedDeparture: PlaceResponse.Node?
    // 
    @Published var showError: String?
    @Published private var airportList: [PlaceResponse.Node] = []
    @Published var airportToShowList: [PlaceResponse.Node] = []
    @Published var flightsList: [FlightsResponse.Itinerary] = []
    
    @Published var prefferedFlight: FlightsResponse.Itinerary?
    
    @Published var isConfirmButtonEnabled: Bool = false
    @Published var isDestinationActive: Bool = false
    @Published var isDepartureActive: Bool = false
    
    @Published var isPrefferedFlightPresent: Bool = false
    
    @Published var isFlightResultsPresented: Bool = false
    
    init(
        service: DataProtocol,
        storage: LocalStorage,
        page: Int
    ) {
        self.storage = storage
        self.page = page
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
            .assign(to: &$airportList)
        
        Publishers.CombineLatest(
            $isDestinationActive,
            $airportList
        )
            .filter { $0.0 }
            .map { Array(OrderedSet($0.1).subtracting(storage.takenDestinations)) }
            .assign(to: &$airportToShowList)
        
        Publishers.CombineLatest(
            $isDepartureActive,
            $airportList
        )
            .filter { $0.0 }
            .map { Array(OrderedSet($0.1).subtracting(storage.takenDepartures)) }
            .assign(to: &$airportToShowList)
        
        // manage departure
        departureEntry
            .map { _ in true }
            .assign(to: &$isDepartureActive)
        
        departureEntry
            .map { _ in false }
            .assign(to: &$isDestinationActive)
        
        let assignedDeparture = selectedDepartureId
            .map { [weak self] id in
                self?.airportList.first { $0.id == id && id != self?.selectedDestination?.id }
            }
        
        assignedDeparture
            .compactMap { $0?.name }
            .assign(to: &$departure)
        
        assignedDeparture
            .compactMap { $0 }
            .assign(to: &$selectedDeparture)
        
        confirm.withLatestFrom($selectedDeparture)
            .compactMap { $0 }
            .sink { storage.takenDepartures.append($0) }
            .store(in: &cancellables)
        
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
            .map { [weak self] id in
                self?.airportList.first { $0.id == id && id != self?.selectedDeparture?.id }
            }
        
        assignedDestination
            .compactMap { $0 }
            .assign(to: &$selectedDestination)
        
        confirm.withLatestFrom($selectedDestination)
            .compactMap { $0 }
            .sink { storage.takenDestinations.append($0) }
            .store(in: &cancellables)
        
        assignedDestination
            .compactMap { $0?.name }
            .assign(to: &$destination)
        
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
            .withLatestFrom($selectedDeparture, $selectedDestination)
            .flatMapLatest { service.retrieveFlights(query: .init(departure: $0.0?.id ?? "",
                                                                  destination: $0.1?.id ?? "")).materialize() }
        
        flightsResult.values()
            .compactMap { $0.data.onewayItineraries?.itineraries }
            .assign(to: &$flightsList)
        
        $flightsList.dropFirst()
            .map { _ in true }
            .assign(to: &$isFlightResultsPresented)
        
        Publishers.Merge(
            placesResult.failures(),
            flightsResult.failures()
        )
            .map { $0.localizedDescription }
            .assign(to: &$showError)
        
        //
        $prefferedFlight
            .filter { $0 != nil }
            .delay(for: 0.3, scheduler: RunLoop.main)
            .map { _ in true }
            .assign(to: &$isPrefferedFlightPresent)
        
        $prefferedFlight
            .dropFirst()
            .filter { $0 == nil }
            .delay(for: 0.3, scheduler: RunLoop.main)
            .map { _ in false }
            .assign(to: &$isPrefferedFlightPresent)
    }
}

extension FlightSearchViewModel {
    func manageInitialValues() {
        isDepartureActive = false
        isDestinationActive = false
    }
    
    func assignPrefferedFlight(_ data: FlightsResponse.Itinerary) {
        isFlightResultsPresented = false
        prefferedFlight = data
    }
    
    func dropFlightsList() {
        resetState()
        isFlightResultsPresented = false
        manageInitialValues()
    }
    
    func resetState() {
        prefferedFlight = nil
        storage.takenDestinations.removeAll { $0.id == selectedDestination?.id }
        destination = ""
        storage.takenDepartures.removeAll { $0.id == selectedDeparture?.id }
        departure = ""
        isConfirmButtonEnabled = false
    }
}
