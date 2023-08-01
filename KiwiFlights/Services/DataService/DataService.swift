//
//  DataService.swift
//  KiwiFlights
//
//  Created by Tomas Baculák on 22/07/2023.
//

import Foundation
import Combine

struct AnyEncodable: Encodable {
    var value: Encodable
        init(_ value: Encodable) {
            self.value = value
        }
        func encode(to encoder: Encoder) throws {
            try value.encode(to: encoder)
        }
}

protocol GraphQueryProtocol {
    var query: String { get }
    var variables: AnyEncodable { get }
}

protocol PaylodProtocol: Encodable, GraphQueryProtocol {}

struct Payload: PaylodProtocol {
    let query: String
    let variables: AnyEncodable
    
    init(
        query: String,
        variables: Encodable
    ) {
        self.query = query
        self.variables = AnyEncodable(variables)
    }
}

protocol DataProtocol {
    func retrievePlaces(query: PlaceQuery) -> AnyPublisher<PlaceResponse, Error>
    func retrieveFlights(query: FlightsQuery) -> AnyPublisher<FlightsResponse, Error>
}

final class DataService: DataProtocol {
    func retrieveFlights(query: FlightsQuery) -> AnyPublisher<FlightsResponse, Error> {
        apiCall(response: FlightsResponse.self,
                payload: Payload(query: query.query, variables: query.variables))
    }
    
    func retrievePlaces(query: PlaceQuery) -> AnyPublisher<PlaceResponse, Error> {
        apiCall(response: PlaceResponse.self,
                payload: Payload(query: query.query, variables: query.variables))
    }
}

extension DataService {
    private func apiCall<T: Decodable>(
        response: T.Type,
        payload: PaylodProtocol
    ) -> AnyPublisher<T, Error> {
        guard let url = URL(string: "https://api.skypicker.com/umbrella/v2/graphql") else {
            return Fail(error: NSError(domain: "Not valid URL", code: 1))
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        request.httpBody = try? JSONEncoder().encode(payload)
        
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
