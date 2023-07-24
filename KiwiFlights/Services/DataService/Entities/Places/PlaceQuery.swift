//
//  PlaceQuery.swift
//  KiwiFlights
//
//  Created by Tomas Baculák on 22/07/2023.
//

import Foundation

struct PlaceQuery {
    let query: String
    private let searchString: String
    
    init(searchString: String = "") {
        self.searchString = searchString
        query =
        """
            query places {
                places(
                    search: { term: "\(searchString)" },
                    filter: {
                        onlyTypes: [AIRPORT, CITY],
                        groupByCity: true
                    },
                    options: { sortBy: RANK },
                    first: 20
                ) {
                ... on PlaceConnection {
                        edges { node { id legacyId name gps { lat lng } } }
                    }
                }
            }
        """
    }
}
