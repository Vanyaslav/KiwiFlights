//
//  FlightsQuery.swift
//  KiwiFlights
//
//  Created by Tomas Baculák on 23/07/2023.
//

import Foundation

struct FlightsQuery {
    let variables: Encodable
    let query: String
    // possibly date or any other paramater could be dynamic
    struct Variable: Encodable {
        let departure: String
        let destination: String
    }
    
    init(
        departure: String = "City:brno_cz",
        destination: String = "City:new-york-city_ny_us"
    ) {
        variables = Variable(departure: departure, destination: destination)
        query =
            """
                fragment stopDetails on Stop {
                    utcTime
                    localTime
                    station { id name code type city { id legacyId name country { id name } } }
                }
                query GetOnewayItineraries($departure: String!, $destination: String!)  {
                    onewayItineraries(
                        filter: {
                            allowChangeInboundSource: false,
                            allowChangeInboundDestination: false,
                            allowDifferentStationConnection: true,
                            allowOvernightStopover: true,
                            contentProviders: [KIWI],
                            limit: 10,
                            showNoCheckedBags: true,
                            transportTypes: [FLIGHT]
                        }, options: {
                            currency: "EUR", partner: "skypicker", sortBy: QUALITY,
                            sortOrder: ASCENDING, sortVersion: 4, storeSearch: true
                        }, search: {
                            cabinClass: { applyMixedClasses: true, cabinClass: ECONOMY },
                        itinerary: {
                            source: { ids: [$departure] },
                            destination: { ids: [$destination] },
                            outboundDepartureDate: {
                                start: "2023-11-01T00:00:00",
                                end: "2023-12-01T23:59:00"
                            }
                        },
                        passengers: { adults: 1, adultsHandBags: [1], adultsHoldBags: [0] }
                        }
                    ) {
                        ... on Itineraries {
                        itineraries {
                        ... on ItineraryOneWay {
                            id duration cabinClasses priceEur { amount }
                            bookingOptions {
                                edges {
                                    node { bookingUrl price { amount formattedValue } }
                                    }
                                }
                            provider { id name code }
                            sector {
                                id duration
                                sectorSegments {
                                    segment {
                                        id duration type code
                                        source { ...stopDetails }
                                        destination { ...stopDetails }
                                        carrier { id name code }
                                        operatingCarrier { id name code }
                                    }
                                    layover { duration isBaggageRecheck transferDuration transferType }
                                    guarantee
                                }
                            }
                        }
                    }
                }
            }
        }
    """
    }
}
