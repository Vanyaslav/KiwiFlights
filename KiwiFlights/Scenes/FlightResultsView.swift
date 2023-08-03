//
//  FlightResultsView.swift
//  KiwiFlights
//
//  Created by Tomas Baculák on 23/07/2023.
//

import SwiftUI


struct FlightResultsView: View {
    @ObservedObject
    private var viewModel: FlightResultsViewModel
    
    init(viewModel: FlightResultsViewModel) {
        _viewModel = .init(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack {
            Image(systemName: "xmark.circle")
                .frame(maxWidth: .infinity, alignment: .leading)
                .onTapGesture {
                    viewModel.dropFlightsList.send()
                }.padding(.bottom, 16)
            HStack {
                Text(viewModel.list.first?.departureCityName ?? "" )
                Text("->")
                Text(viewModel.list.first?.destinationCityName ?? "")
                    
            }
                .font(.title)
                .fontWeight(.heavy)
            
            ScrollView {
                ForEach(viewModel.list, id: \.self.id) {
                    ItemView($0)
                }
            }
        }.padding(16)
    }
}

extension FlightResultsView {
    func ItemView(_ data: FlightsResponse.Itinerary) -> some View {
        HStack {
            Text(data.sector?.sectorSegments.first?.segment.source.localTime.shortTimeNormal ?? "")
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack {
                Text(data.duration?.hoursFormatFromSecondsShort ?? "")
                Text(data.flightPrice)
                    .padding(.leading, 16)
            }.frame(maxWidth: .infinity, alignment: .trailing)
                
        }
            .contentShape(Rectangle())
            .padding(.bottom, 16)
            .onTapGesture {
                viewModel.assignPrefferedFlight.send(data)
            }
    }
}

struct FlightResultsView_Previews: PreviewProvider {
    static var previews: some View {
        FlightResultsView(viewModel: .init())
    }
}
