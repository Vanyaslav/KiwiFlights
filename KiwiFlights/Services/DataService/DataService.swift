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

protocol GraphQueryProtocol: Encodable {
    var query: String { get }
    var variables: AnyEncodable { get }
}

struct Payload: GraphQueryProtocol {
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
    var url: URL? {
        URL(string: "https://api.skypicker.com/umbrella/v2/graphql")
    }
    
    func request(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }
}

extension DataService {
    private func apiCall<T: Decodable>(
        response: T.Type,
        payload: GraphQueryProtocol
    ) -> AnyPublisher<T, Error> {
        guard let url = url else {
            return Fail(error: NSError(domain: "Not valid URL", code: 1))
                .eraseToAnyPublisher()
        }
        
        var request = request(url: url)
        // even the GraphQueryProtocol conforms to Encdable -> for the sake of things, let's make it as a complete solution
        do {
            request.httpBody = try JSONEncoder().encode(payload)
        } catch {
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
        
        debugPrint(payload)
        
        return URLSession.shared
            .dataTaskPublisher(for: request)
            .tryMap { $0.data }
            .decode(type: response.self, decoder: JSONDecoder())
            .print()
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
