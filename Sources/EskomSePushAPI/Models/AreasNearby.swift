//
//  AreasNearby.swift
//  LoadShedding
//
//  Created by Ian Weatherburn on 2023/03/22.
//

import Foundation

protocol AreasNearbyServiceable {
    func getAreasNearby(latitude lat: Double,
                        longitude lon: Double,
                        with token: String) async throws -> AreasNearby
}

struct AreasNearbyService: HTTPClient, AreasNearbyServiceable {
    func getAreasNearby(latitude lat: Double,
                        longitude lon: Double,
                        with token: String) async throws -> AreasNearby {
        return try await sendRequest(to: EskomSePushEndpoint.areasNearby(lat: lat, lon: lon),
                                     returning: AreasNearby.self,
                                     with: token)
    }
}

public struct AreasNearby: Decodable {
    let areas: [AreaNearby]
}

public struct AreaNearby: Decodable {
    let count: Int
    let id: String
    let name: String
    let region: String
}
