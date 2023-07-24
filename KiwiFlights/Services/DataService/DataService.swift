//
//  DataService.swift
//  KiwiFlights
//
//  Created by Tomas Baculák on 22/07/2023.
//

import Foundation
import Combine

protocol DataProtocol {
    func retrievePlaces(query: PlaceQuery) -> AnyPublisher<PlaceResponse, Error>
    func retrieveFlights(query: FlightsQuery) -> AnyPublisher<FlightsResponse, Error>
}

struct Payload: Encodable {
    var query: String
}

class DataService: DataProtocol {
    func retrieveFlights(query: FlightsQuery) -> AnyPublisher<FlightsResponse, Error> {
        guard let url = URL(string: "https://api.skypicker.com/umbrella/v2/graphql") else {
            return Fail(error: NSError(domain: "Not valid URL", code: 1))
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let payload = Payload(query: query.query)
        let postData = try? JSONEncoder().encode(payload)
        request.httpBody = postData
        
        print(payload)
        
        return URLSession.shared
            .dataTaskPublisher(for: request)
            .tryMap { $0.data }
            .decode(type: FlightsResponse.self, decoder: JSONDecoder())
            .print()
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func retrievePlaces(query: PlaceQuery = .init()) -> AnyPublisher<PlaceResponse, Error> {
        guard let url = URL(string: "https://api.skypicker.com/umbrella/v2/graphql") else {
            return Fail(error: NSError(domain: "Not valid URL", code: 1))
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let payload = Payload(query: query.query)
        let postData = try? JSONEncoder().encode(payload)
        request.httpBody = postData
        
        print(payload)
        
        return URLSession.shared
            .dataTaskPublisher(for: request)
            .tryMap { $0.data }
            .decode(type: PlaceResponse.self, decoder: JSONDecoder())
            .print()
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
