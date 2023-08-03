//
//  FlightSearchView.swift
//  KiwiFlights
//
//  Created by Tomas Baculák on 22/07/2023.
//

import SwiftUI
import Combine
// import Orbit

struct FlightSearchView: View {
    @ObservedObject
    private var viewModel: FlightSearchViewModel
    @EnvironmentObject
    private var router: AppRouter
    
    @FocusState private var departureFocused: Bool
    @FocusState private var destinationFocused: Bool
    
    init(viewModel: FlightSearchViewModel) {
        _viewModel = .init(wrappedValue: viewModel)
    }
    
    var body: some View {
        if !viewModel.isPreferredFlightPresent {
            SearchOffer()
        } else {
            FlightOffer()
        }
    }
}

extension FlightSearchView {
    func SearchOffer() -> some View {
        VStack {
            Text(viewModel.searchTitle)
                .font(.largeTitle)
                .padding(.bottom, 32)
            HStack {
                ManageDeparture()
                ManageDestination()
            }
            Spacer()
            ComfirmButton()
        }
            .padding(.all, 32)
            .fullScreenCover(isPresented: $viewModel.isFlightResultsPresented) {
                router.showFlightResultView(viewModel.resultsViewModel)
            }
            .onAppear {
                viewModel.manageInitialValues.send()
            }
    }
    
    func ManageDeparture() -> some View {
        VStack {
            Text("Departure")
                .frame(maxWidth: .infinity, alignment: .leading)
            
            TextField("From", text: $viewModel.departure)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
                .focused($departureFocused)
            
            if viewModel.isDepartureActive {
                ScrollView {
                    ForEach(viewModel.airportToShowList, id: \.self) { item in
                        Text(item.name ?? "")
                            .tag(item.id)
                            .padding(.bottom, 8)
                            .onTapGesture {
                                viewModel.selectedDeparture = item
                            }
                    }
                }.frame(maxHeight: 200)
            }
            Spacer()
        }
    }
    
    func ManageDestination() -> some View {
        VStack {
            Text("Destination")
                .frame(maxWidth: .infinity, alignment: .leading)
            
            TextField("To", text: $viewModel.destination)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
                .focused($destinationFocused)
            
            if viewModel.isDestinationActive {
                ScrollView {
                    ForEach(viewModel.airportToShowList, id: \.self) { item in
                        Text(item.name ?? "")
                            .tag(item.id)
                            .padding(.bottom, 8)
                            .onTapGesture {
                                viewModel.selectedDestination = item
                            }
                    }
                }.frame(maxHeight: 200)
            }
            Spacer()
        }
    }
    
    func ComfirmButton() -> some View {
        Button("CONFIRM") {
            viewModel.confirm.send()
            departureFocused = false
            destinationFocused = false
        }
            .disabled(!viewModel.isConfirmButtonEnabled)
            .opacity(viewModel.isConfirmButtonEnabled ? 1.0 : 0.3)
            .foregroundColor(.teal)
            .font(.largeTitle)
            .padding(.bottom, 16)
    }
}

extension FlightSearchView {
    func FlightOffer() -> some View {
        VStack {
            Button("New search") {
                viewModel.reset.send()
            }
            
            Spacer()
            Text(viewModel.offerTitle)
                .font(.largeTitle)
                .fontWeight(.thin)
            DestinationImage()
            Spacer()
            RouteView()
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
    
    func RouteView() -> some View {
        VStack {
            VStack {
                Text("From")
                Text(viewModel.departureCityName)
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .padding([.leading, .trailing], 32)
            }.frame(maxWidth: .infinity, alignment: .leading)
            
            VStack {
                Text("To")
                Text(viewModel.destinationCityName)
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .padding([.leading, .trailing], 32)
            }.frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
    
    func DestinationImage() -> some View {
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
    }
}

struct FlightSearch_Previews: PreviewProvider {
    static var previews: some View {
        FlightSearchView(viewModel: .init(service: DataService(),
                                          storage: .init(),
                                          page: 1))
    }
}
