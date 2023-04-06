//
//  Status.swift
//  LoadShedding
//
//  Created by Ian Weatherburn on 2023/03/21.
//

import Foundation

protocol StatusServiceable {
    func getStatus(with token: String) async throws -> Status
}

struct StatusService: HTTPClient, StatusServiceable {
    func getStatus(with token: String) async throws -> Status {
        return try await sendRequest(to: EskomSePushEndpoint.status,
                                     returning: Status.self,
                                     with: token)
    }
}

public struct Status: Decodable {
    let cities: Cities
    
    enum CodingKeys: String, CodingKey {
        case cities = "status"
    }
}

public struct Cities: Decodable {
    let capeTown: City
    let eskom: City
    
    enum CodingKeys: String, CodingKey {
        case capeTown = "capetown"
        case eskom
    }
}

public struct City: Decodable {
    let name: String
    let stage: Int
    let nextStages: [NextStage]
    let stageUpdated: Date
    
    enum CodingKeys: String, CodingKey {
        case name
        case stage
        case nextStages = "next_stages"
        case stageUpdated = "stage_updated"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        let stageString = try container.decode(String.self, forKey: .stage)
        stage = Int(stageString) ?? 0
        nextStages = try container.decode([NextStage].self, forKey: .nextStages)
        stageUpdated = try container.decode(String.self, forKey: .stageUpdated).ISO8601Date()
    }
}
 
public struct NextStage: Decodable {
    let stage: Int
    let stageStartDateTime: Date
    
    enum CodingKeys: String, CodingKey {
        case stage
        case stageStartDateTime = "stage_start_timestamp"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let stageString = try container.decode(String.self, forKey: .stage)
        stage = Int(stageString) ?? 0
        stageStartDateTime = try container.decode(String.self, forKey: .stageStartDateTime).ISO8601Date()
    }
}

extension NextStage {
    var stageStartDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, MMM d"
        return dateFormatter.string(from: self.stageStartDateTime)
    }
    
    var startStartTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: self.stageStartDateTime)
    }
}

