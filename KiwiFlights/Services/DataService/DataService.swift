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

final class DataService: DataProtocol {
    func retrieveFlights(query: FlightsQuery) -> AnyPublisher<FlightsResponse, Error> {
        apiCall(response: FlightsResponse.self, query: query)
    }
    
    func retrievePlaces(query: PlaceQuery = .init()) -> AnyPublisher<PlaceResponse, Error> {
        apiCall(response: PlaceResponse.self, query: query)
    }
}

extension DataService {
    private func apiCall<T: Decodable>(
        response: T.Type,
        query: GraphQueryProtocol
    ) -> AnyPublisher<T, Error> {
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
            .decode(type: response.self, decoder: JSONDecoder())
            .print()
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
