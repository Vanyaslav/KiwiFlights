//
//  FlightResultsView.swift
//  KiwiFlights
//
//  Created by Tomas Baculák on 23/07/2023.
//

import SwiftUI

struct FlightResultsView: View {
    private let viewModel: FlightSearchViewModel
    
    init(viewModel: FlightSearchViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            Image(systemName: "xmark.circle")
                .frame(maxWidth: .infinity, alignment: .trailing)
                .onTapGesture {
                    viewModel.isFlightResultsPresented = false
                }.padding(.bottom, 16)
            
            ScrollView {
                ForEach(viewModel.flightsList, id: \.self.id) {
                    ItemView($0)
                }
            }
        }.padding(16)
    }
}

extension FlightResultsView {
    func ItemView(_ data: FlightsResponse.Itinerary) -> some View {
        HStack {
            HStack {
                Text(data.departureCityName)
                Text(data.destinationCityName)
            }.frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                Text(data.duration?.hoursFormatFromSecondsShort ?? "")
                Text(data.flightPrice)
                    .padding(.leading, 16)
            }.frame(maxWidth: .infinity, alignment: .trailing)
                
        }
        .padding(.bottom, 16)
        .onTapGesture {
            viewModel.assignPrefferedFlight(data)
        }
    }
}

struct FlightResultsView_Previews: PreviewProvider {
    static var previews: some View {
        FlightResultsView(viewModel: .init(service: DataService(), storage: .init(), page: 1))
    }
}
