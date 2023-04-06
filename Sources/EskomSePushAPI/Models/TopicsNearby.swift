//
//  TopicsNearby.swift
//  LoadShedding
//
//  Created by Ian Weatherburn on 2023/03/22.
//

import Foundation

protocol TopicsNearbyServiceable {
    func getTopicsNearby(latitude lat: Double,
                         longitude lon: Double,
                         with token: String) async throws -> TopicsNearby
}

struct TopicsNearbyService: HTTPClient, TopicsNearbyServiceable {
    func getTopicsNearby(latitude lat: Double,
                         longitude lon: Double,
                         with token: String) async throws -> TopicsNearby {
        return try await sendRequest(to: EskomSePushEndpoint.topicsNearby(lat: lat, lon: lon),
                                     returning: TopicsNearby.self,
                                     with: token)
    }
}

public struct TopicsNearby: Decodable {
    let topics: [Topics]
}

public struct Topics: Decodable {
    let active: Date
    let body: String
    let category: String
    let distance: Double
    let followers: Int
    let timestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case active
        case body
        case category
        case distance
        case followers
        case timestamp
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        active = try container.decode(String.self, forKey: .active).ISO8601Date()
        body = try container.decode(String.self, forKey: .body)
        category = try container.decode(String.self, forKey: .category)
        distance = try container.decode(Double.self, forKey: .distance)
        followers = try container.decode(Int.self, forKey: .followers)
        timestamp = try container.decode(String.self, forKey: .timestamp).ISO8601Date()
    }
    
    enum Category: String {
        case advice = "Advice"
        case electricity = "Electricity"
        case water = "Water"
        case goodVibes = "Good Vibes"
        case internet = "Internet"
        case roads = "Roads"
        case missingPets = "Missing Pets"
        case events = "Events"
        case fires = "Fires"
        case safety = "Safety"
        case gaming = "Gaming"
    }
}
