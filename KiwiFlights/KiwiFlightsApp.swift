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
        let dataService = dataService
        let localStorage = localStorage
        return TabView(selection: selectedPage) {
            ForEach((1...5), id: \.self) {
                FlightSearchView(
                    viewModel: .init(service: dataService,
                                     storage: localStorage,
                                     page: $0)
                )
            }
        }.tabViewStyle(.page(indexDisplayMode: .always))
    }
}
