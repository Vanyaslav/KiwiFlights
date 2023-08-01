//
//  KiwiFlightsTests.swift
//  KiwiFlightsTests
//
//  Created by Tomas Baculák on 31/07/2023.
//

import XCTest
@testable import KiwiFlights

final class KiwiFlightsTests: XCTestCase {

    func testSearchViewModelDeallocation() {
        let model: FlightSearchViewModel? = FlightSearchViewModel(service: DataService(),
                                                                  storage: .init(),
                                                                  page: 1)
        
        addTeardownBlock { [weak model] in
            XCTAssertNil(model, "View model should be deallocated ⚠️")
        }
    }
}
