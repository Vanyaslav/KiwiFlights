//
//  PlaceResponse.swift
//  KiwiFlights
//
//  Created by Tomas Baculák on 22/07/2023.
//

import Foundation

struct PlaceResponse: Decodable {
    let data: Data
}

extension PlaceResponse {
    struct Coordinate: Codable {
        let lat: Double?
        let lng: Double?
    }
    
    struct Node: Codable {
        let id: String
        let legacyId: String
        let name: String?
        let gps: Coordinate?
    }

    struct Nodes: Decodable {
        let node: Node
    }

    struct Places: Decodable {
        let edges: [Nodes]
    }

    struct Data: Decodable {
        let places: Places
    }
}

extension PlaceResponse.Node: Identifiable, Hashable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    var identifier: String { id }
}
