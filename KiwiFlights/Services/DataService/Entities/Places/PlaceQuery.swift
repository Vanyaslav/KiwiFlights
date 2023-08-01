//
//  PlaceQuery.swift
//  KiwiFlights
//
//  Created by Tomas Baculák on 22/07/2023.
//

import Foundation


struct PlaceQuery {
    let variables: Encodable
    let query: String
    
    struct Variable: Encodable {
        let term: String
    }
    
    init(searchString: String = "") {
        variables = Variable(term: searchString)
        query =
        """
            query GetPlaces($term: String!) {
                places(
                    search: { term: $term },
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
