//
//  Publisher+Bind.swift
//  KiwiFlights
//
//  Created by Tomas Baculák on 30/07/2023.
//

import Foundation
import Combine

extension Publisher where Output: Equatable {
    func bind<T>(to publisher: inout Published<T>.Publisher) where T: Equatable {
        removeDuplicates()
            .ignoreFailure()
            .receive(on: DispatchQueue.main)
            .compactMap { $0 as? T }
            .assign(to: &publisher)
    }
}
