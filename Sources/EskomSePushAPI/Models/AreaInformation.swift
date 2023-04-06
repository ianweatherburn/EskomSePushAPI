//
//  AreaInformation.swift
//  LoadShedding
//
//  Created by Ian Weatherburn on 2023/03/22.
//

import Foundation

/*
https://documenter.getpostman.com/view/1296288/UzQuNk3E#1881472b-c959-4259-b574-177feb5e0cda
Include the &test=current or &test=future to get SAMPLE data returned in the events. current will return a loadshedding event which is occurring right now, 
and future will return an event starting on the next hour.

NOTE: The schedule returned with testing data is NOT accurate data; but only for testing purposes. 
The area name and source is updated to identify that this is testing data. 
This test request will not count towards your quota
*/

protocol AreaInformationServiceable {
    func getAreaInformation(area: String,
                            with token: String,
                            test: Testing?) async throws -> AreaInformation
}

struct AreaInformationService: HTTPClient, AreaInformationServiceable {
    func getAreaInformation(area: String,
                            with token: String,
                            test: Testing? = nil) async throws -> AreaInformation {
        return try await sendRequest(to: EskomSePushEndpoint.areaInformation(areaID: area, test: test),
                                     returning: AreaInformation.self,
                                     with: token)
    }
}

public struct AreaInformation: Decodable {
    let events: [Event]
    let info: Info
    let schedule: Schedule
}

public struct Schedule: Decodable {
    let days: [Day]
    let source: String
}

public struct Day: Decodable {
    let date: String
    let name: String
    let stages: [[String]]
}

public struct Info: Decodable {
    let name: String
    let region: String
}

public struct Event: Decodable {
    let note: String
    let start: Date
    let end: Date

    enum CodingKeys: String, CodingKey {
        case note
        case start
        case end
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        note = try container.decode(String.self, forKey: .note)
        start = try container.decode(String.self, forKey: .start).ISO8601Date()
        end = try container.decode(String.self, forKey: .end).ISO8601Date()
    }
}

extension Event {
    var eventStartTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: self.start)
    }
    var eventEndTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: self.end)
    }
}

