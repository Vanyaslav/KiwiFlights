//
//  KiwiFlightsApp.swift
//  KiwiFlights
//
//  Created by Tomas Baculák on 22/07/2023.
//

import SwiftUI

@main
struct KiwiFlightsApp: App {
    @State var selectedPage: Int = 0
    
    var body: some Scene {
        WindowGroup {
            AppRouter()
                .mainView(selectedPage: $selectedPage)
        }
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
    
    func mainView(selectedPage: Binding<Int>) -> some View {
        TabView(selection: selectedPage) {
            ForEach((1...5), id: \.self) {
                self.flightSearchView(page: $0)
            }
        }.tabViewStyle(.page(indexDisplayMode: .always))
    }
    
    func flightSearchView(page: Int) -> FlightSearchView {
        .init(
            viewModel: .init(service: dataService,
                             storage: localStorage,
                             page: page)
        )
    }
}
