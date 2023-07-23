//
//  FlightSearchView.swift
//  KiwiFlights
//
//  Created by Tomas Baculák on 22/07/2023.
//

import SwiftUI
import Orbit

struct FlightSearchView: View {
    let page: Int
    @ObservedObject var viewModel: FlightSearchViewModel
    
    init(
        page: Int,
        viewModel: FlightSearchViewModel = .init()
    ) {
        self.page = page
        self.viewModel = viewModel
    }
    
    var body: some View {
        if !viewModel.isPrefferedFlightPresent {
            VStack {
                Text("Choose your route")
                    .font(.largeTitle)
                    .padding(.bottom, 32)
                HStack {
                    VStack {
                        Text("Departure")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        TextField("From", text: $viewModel.departure)
                            .textFieldStyle(.roundedBorder)
                            .autocorrectionDisabled()
                        
                        if viewModel.isDepartureActive {
                            ScrollView {
                                ForEach(viewModel.airportList, id: \.self) { item in
                                    Text(item.name ?? "")
                                        .tag(item.id)
                                        .onTapGesture {
                                            viewModel.selectedDepartureId.send(item.id)
                                        }
                                }
                            }.frame(maxHeight: 180)
                        }
                        Spacer()
                    }
                    
                    VStack {
                        Text("Destination")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        TextField("To", text: $viewModel.destination)
                            .textFieldStyle(.roundedBorder)
                            .autocorrectionDisabled()
                        
                        if viewModel.isDestinationActive {
                            ScrollView {
                                ForEach(viewModel.airportList, id: \.self) { item in
                                    Text(item.name ?? "")
                                        .tag(item.id)
                                        .onTapGesture {
                                            viewModel.selectedDestinationId.send(item.id)
                                        }
                                }
                            }.frame(maxHeight: 180)
                        }
                        Spacer()
                    }
                }
                
                Spacer()
                
                Button("Confirm") { viewModel.confirm.send() }
                    .disabled(!viewModel.isConfirmButtonEnabled)
                    .opacity(viewModel.isConfirmButtonEnabled ? 1.0: 0.3)
            }
                .padding(.all, 32)
                .fullScreenCover(isPresented: $viewModel.isFlightResultsPresented) {
                    FlightResultsView(viewModel: viewModel)
                }
                .onAppear {
                    viewModel.isDepartureActive = false
                    viewModel.isDestinationActive = false
                }
        } else {
            VStack {
                Button("New search") { viewModel.prefferedFlight = nil }
                Text(viewModel.prefferedFlight?.sector?.sectorSegments.first?.segment.source.station.city.name ?? "")
                Text(viewModel.prefferedFlight?.sector?.sectorSegments.last?.segment.destination.station.city.name ?? "")
            }
        }
        
    }
}

struct FlightSearch_Previews: PreviewProvider {
    static var previews: some View {
        FlightSearchView(page: 1)
    }
}
