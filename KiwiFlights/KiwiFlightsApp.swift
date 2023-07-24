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
    
//    init(selectedPage: Int = 0) {
//        _selectedPage = selectedPage
//    }
    
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
    let dataService: DataProtocol
    
    init(dataService: DataProtocol = DataService()) {
        self.dataService = dataService
    }
    
    func flightSearchView(page: Int, selectedPage: Binding<Int>) -> FlightSearchView {
        .init(viewModel: .init(service: dataService, page: page),
        selectedPage: selectedPage)
    }
}
