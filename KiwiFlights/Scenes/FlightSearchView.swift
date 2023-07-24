//
//  FlightSearchView.swift
//  KiwiFlights
//
//  Created by Tomas Baculák on 22/07/2023.
//

import SwiftUI
import Orbit

struct FlightSearchView: View {
    @ObservedObject var viewModel: FlightSearchViewModel
    
    init(viewModel: FlightSearchViewModel) {
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
                                ForEach(viewModel.airportToShowList, id: \.self) { item in
                                    Text(item.name ?? "")
                                        .tag(item.id)
                                        .onTapGesture {
                                            viewModel.selectedDepartureId.send(item.id)
                                        }
                                }
                            }.frame(maxHeight: 200)
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
                                ForEach(viewModel.airportToShowList, id: \.self) { item in
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
                    .padding(.bottom, 16)
            }
                .padding(.all, 32)
                .fullScreenCover(isPresented: $viewModel.isFlightResultsPresented) {
                    FlightResultsView(viewModel: viewModel)
                }
                .onAppear {
                    viewModel.manageInitialValues()
                }
        } else {
            VStack {
                Button("New search") {
                    viewModel.resetState()
                }
                
                Spacer()
                
                Text("FLIGHT OFFER")
                
                AsyncImage(url: viewModel.prefferedFlightURL) { image in
                    image.resizable()
                        .scaledToFill()
                } placeholder: {
                    ProgressView()
                }
                    .frame(width: 300, height: 300)
                    .background(Color.gray)
                    .clipShape(Circle())
                    .padding(16)
                
                Spacer()
                
                VStack {
                    Text(viewModel.departureCityName)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(viewModel.destinationCityName)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .padding([.leading, .trailing], 32)
                
                Spacer()
                
                HStack {
                    Text(viewModel.stopTitle)
                    Text("-->")
                    Text(viewModel.durationTitle)
                }.font(.subheadline)
                
                Text(viewModel.flightPrice)
                    .font(.subheadline)
                    .fontWeight(.heavy)
                
                Spacer()
                
            }.padding(16)
        }
    }
}

struct FlightSearch_Previews: PreviewProvider {
    static var previews: some View {
        FlightSearchView(viewModel: .init(service: DataService(), page: 1))
    }
}
