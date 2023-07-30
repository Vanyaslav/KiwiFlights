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
    let page: Int
    // in
    let confirm = PassthroughSubject<Void, Never>()
    let reset = PassthroughSubject<Void, Never>()
    let manageInitialValues = PassthroughSubject<Void, Never>()
    let dropFlightsList = PassthroughSubject<Void, Never>()
    let assignPrefferedFlight = PassthroughSubject<FlightsResponse.Itinerary, Never>()
    
    @Published var selectedDestination: PlaceResponse.Node?
    @Published var selectedDeparture: PlaceResponse.Node?
    // in - out
    @Published var departure: String = ""
    @Published var destination: String = ""
    // out
    @Published private (set) var showError: String?
    @Published private var airportList: [PlaceResponse.Node] = []
    @Published private (set) var airportToShowList: [PlaceResponse.Node] = []
    @Published private (set) var flightsList: [FlightsResponse.Itinerary] = []
    
    @Published private (set) var preferredFlight: FlightsResponse.Itinerary?
    
    @Published private (set) var isConfirmButtonEnabled: Bool = false
    @Published private (set) var isDestinationActive: Bool = false
    @Published private (set) var isDepartureActive: Bool = false
    
    @Published private (set) var isPreferredFlightPresent: Bool = false
    
    @Published var isFlightResultsPresented: Bool = false
    
    init(
        service: DataProtocol,
        storage: LocalStorage,
        page: Int
    ) {
        self.page = page
        
        let departureEntry = $departure.dropFirst(2)
            .withLatestFrom($airportToShowList) { ($0, $1) }
            .filter { (entry, list) in !list.contains { $0.name == entry } }
            .map { $0.0 }
        
        let destinationEntry = $destination.dropFirst(2)
            .withLatestFrom($airportToShowList) { ($0, $1) }
            .filter { (entry, list) in !list.contains { $0.name == entry } }
            .map { $0.0 }
        
        let placesResult = Publishers.Merge(
            departureEntry,
            destinationEntry
        )
            .removeDuplicates()
            .throttle(for: 1.5, scheduler: RunLoop.main, latest: true)
            .flatMapLatest { service.retrievePlaces(query: .init(searchString: $0)).materialize() }
            .share()
        
        placesResult.values()
            .map { $0.data.places.edges.map { $0.node } }
            .removeDuplicates()
            .assign(to: &$airportList)
        
        Publishers.Merge(
            Publishers.CombineLatest(
                $isDestinationActive,
                $airportList
            )
                .filter { $0.0 }
                .map { Array(OrderedSet($0.1).subtracting(storage.takenDestinations)) },
            Publishers.CombineLatest(
                $isDepartureActive,
                $airportList
            )
                .filter { $0.0 }
                .map { Array(OrderedSet($0.1).subtracting(storage.takenDepartures)) }
        )
            .assign(to: &$airportToShowList)
        
        // manage departure
        Publishers.Merge(
            departureEntry.map { _ in true },
            Publishers.Merge3(
                $selectedDeparture.mapToVoid(),
                destinationEntry.mapToVoid(),
                manageInitialValues
            ).map { _ in false }
            
        )
            .removeDuplicates()
            .assign(to: &$isDepartureActive)
        
        $selectedDeparture
            .removeDuplicates()
            .map { $0?.name ?? "" }
            .assign(to: &$departure)
        
        confirm.withLatestFrom($selectedDeparture)
            .compactMap { $0 }
            .sink { storage.takenDepartures.append($0) }
            .store(in: &cancellables)
        
        // manage destination
        Publishers.Merge(
            destinationEntry.map { _ in true },
            Publishers.Merge3(
                departureEntry.mapToVoid(),
                $selectedDestination.mapToVoid(),
                manageInitialValues
            ).map { _ in false }
        )
            .removeDuplicates()
            .assign(to: &$isDestinationActive)
        
        $selectedDestination
            .removeDuplicates()
            .map { $0?.name ?? "" }
            .assign(to: &$destination)
        
        confirm.withLatestFrom($selectedDestination)
            .compactMap { $0 }
            .sink { storage.takenDestinations.append($0) }
            .store(in: &cancellables)
        
        //
        Publishers.Merge(
            Publishers.CombineLatest(
                $selectedDeparture,
                $selectedDestination
            )
                .filter { $0.0 != nil && $0.1 != nil }
                .map { _ in true },
            reset.map { _ in false }
        )
            .removeDuplicates()
            .assign(to: &$isConfirmButtonEnabled)
        
        let flightsResult = confirm
            .withLatestFrom($selectedDeparture, $selectedDestination)
            .flatMapLatest { service.retrieveFlights(query: .init(departure: $0.0?.id ?? "",
                                                                  destination: $0.1?.id ?? "")).materialize() }
        
        flightsResult.values()
            .compactMap { $0.data.onewayItineraries?.itineraries }
            .assign(to: &$flightsList)
        
        Publishers.Merge(
            $flightsList.dropFirst().map { _ in true },
            Publishers.Merge(
                dropFlightsList,
                assignPrefferedFlight.mapToVoid()
            ).map { _ in false }
        )
            .removeDuplicates()
            .assign(to: &$isFlightResultsPresented)
        
        Publishers.Merge(
            placesResult.failures(),
            flightsResult.failures()
        )
            .map { $0.localizedDescription }
            .assign(to: &$showError)
        
        //
        Publishers.Merge(
            assignPrefferedFlight.compactMap { $0 },
            reset.map { _ in nil }
        ).assign(to: &$preferredFlight)
        
        $preferredFlight
            .delay(for: 0.3, scheduler: RunLoop.main)
            .map { $0 != nil }
            .removeDuplicates()
            .assign(to: &$isPreferredFlightPresent)
        
        reset.withLatestFrom($selectedDeparture, $selectedDestination)
            .map { storage.reset(destination: $1, departure: $0) }
            .map { _ in nil }
            .assign(to: \.selectedDestination, on: self,
                    and: \.selectedDeparture, on: self,
                    ownership: .weak)
            .store(in: &cancellables)
        
        dropFlightsList
            .subscribe(reset)
            .store(in: &cancellables)
    }
}
