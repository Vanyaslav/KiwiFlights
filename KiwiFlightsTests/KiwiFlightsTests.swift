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
        var model: FlightSearchViewModel? = FlightSearchViewModel(service: DataService(),
                                                                  storage: .init(),
                                                                  page: 1)
        
        weak var weakModel: FlightSearchViewModel?
        
        autoreleasepool {
            weakModel = model
            model = nil
        }

        XCTAssertNil(weakModel, "View model should be deallocated")
    }

}
