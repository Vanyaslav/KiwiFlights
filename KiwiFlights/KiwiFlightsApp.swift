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
            MainView()
        }
    }
}

struct MainView: View {
    @State var selectedPage: Int = 0
    
    var body: some View {
        TabView(selection: $selectedPage) {
            ForEach((1...5), id: \.self) {
                AppRouter()
                    .flightSearchView(page: $0, selectedPage: $selectedPage)
            }
        }.tabViewStyle(.page(indexDisplayMode: .always))
    }
}

class AppRouter {
    private let dataService: DataProtocol
    private let localStorage: LocalStorage
    
    init(
        dataService: DataProtocol = DataService(),
        localStorage: LocalStorage = .init()
    ) {
        self.dataService = dataService
        self.localStorage = localStorage
    }
    
    deinit {
        localStorage.reset()
    }
    
    func flightSearchView(page: Int, selectedPage: Binding<Int>) -> FlightSearchView {
        .init(
            viewModel: .init(service: dataService,
                             storage: localStorage,
                             page: page),
            selectedPage: selectedPage
        )
    }
}
