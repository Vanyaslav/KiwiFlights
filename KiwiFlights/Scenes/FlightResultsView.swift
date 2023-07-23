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
            Text(data.sector?.sectorSegments.first?.segment.source.station.city.name ?? "")
            Text(data.sector?.sectorSegments.last?.segment.destination.station.city.name ?? "")
            Text("\(data.duration ?? 0)")
            Text(data.bookingOptions?.edges.first?.node.price?.formattedValue ?? "")
                .padding(16)
                
        }.onTapGesture {
            viewModel.isFlightResultsPresented = false
            viewModel.prefferedFlight = data
        }
    }
}

struct FlightResultsView_Previews: PreviewProvider {
    static var previews: some View {
        FlightResultsView(viewModel: .init(service: DataService(), page: 1))
    }
}
