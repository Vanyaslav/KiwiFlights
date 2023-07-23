//
//  FlightsQuery.swift
//  KiwiFlights
//
//  Created by Tomas Baculák on 23/07/2023.
//

import Foundation

struct FlightsQuery {
    let query: String
    
    init() {
        query = """
        fragment stopDetails on Stop {
            utcTime
            localTime
            station { id name code type city { id legacyId name country { id name } } }
        }
        query onewayItineraries {
            onewayItineraries(
                filter: {
                    allowChangeInboundSource: false, allowChangeInboundDestination: false,
                    allowDifferentStationConnection: true, allowOvernightStopover: true,
                    contentProviders: [KIWI], limit: 10, showNoCheckedBags: true,
                    transportTypes: [FLIGHT]
                }, options: {
                currency: "EUR", partner: "skypicker", sortBy: QUALITY,
                sortOrder: ASCENDING, sortVersion: 4, storeSearch: true
                }, search: {
                cabinClass: { applyMixedClasses: true, cabinClass: ECONOMY },
                itinerary: {
                    source: { ids: ["City:brno_cz"] },
                    destination: { ids: ["City:new-york-city_ny_us"] },
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
