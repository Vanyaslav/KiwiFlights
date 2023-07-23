//
//  KiwiFlightsApp.swift
//  KiwiFlights
//
//  Created by Tomas Baculák on 22/07/2023.
//

import SwiftUI

@main
struct KiwiFlightsApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                ForEach((1...5), id: \.self) {
                    FlightSearchView(page: $0)
                }
            }.tabViewStyle(.page(indexDisplayMode: .always))
        }
    }
}
