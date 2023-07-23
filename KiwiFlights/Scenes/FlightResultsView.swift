//
//  FlightResultsView.swift
//  KiwiFlights
//
//  Created by Tomas Baculák on 23/07/2023.
//

import SwiftUI

struct FlightResultsView: View {
    @State var flightsList: [FlightsResponse.Itinerary]
    
    init (flightsList: [FlightsResponse.Itinerary]) {
        self.flightsList = flightsList
    }
    
    var body: some View {
        VStack {
            ScrollView {
                ForEach(flightsList, id: \.self.id) {
                    ItemView($0)
                }
            }
        }
        
            .padding(32)
    }
}

extension FlightResultsView {
    func ItemView(_ data: FlightsResponse.Itinerary) -> some View {
        HStack {
            Text(data.sector?.sectorSegments.first?.segment.source.station.city.name ?? "")
            Text(data.sector?.sectorSegments.first?.segment.destination.station.city.name ?? "")
            Text("\(data.duration ?? 0)")
            Text(data.bookingOptions?.edges.first?.node.price?.formattedValue ?? "")
                .padding(16)
                .onTapGesture {
                    
                }
        }
    }
}

struct FlightResultsView_Previews: PreviewProvider {
    static var previews: some View {
        FlightResultsView(flightsList: [])
    }
}
