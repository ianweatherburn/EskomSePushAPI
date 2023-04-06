//
//  AreasSearch.swift
//  LoadShedding
//
//  Created by Ian Weatherburn on 2023/03/22.
//

import Foundation

protocol AreasSearchServiceable {
    func getAreasSearch(_ text: String,
                        with token: String) async throws -> AreasSearch
}

struct AreasSearchService: HTTPClient, AreasSearchServiceable {
    func getAreasSearch(_ text: String,
                        with token: String) async throws -> AreasSearch {
        return try await sendRequest(to: EskomSePushEndpoint.areasSearch(text: text),
                                     returning: AreasSearch.self,
                                     with: token)
    }
}

public struct AreasSearch: Decodable {
    let areas: [AreaSearch]
}

public struct AreaSearch: Decodable {
    let id: String
    let name: String
    let region: String
}
