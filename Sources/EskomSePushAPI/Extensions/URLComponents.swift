//
//  URLComponents.swift
//  LoadShedding
//
//  Created by Ian Weatherburn on 2023/03/21.
//

import Foundation

extension URLComponents {
    mutating func setQueryItems(with parameters: [String: String]) {
        self.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
    }
}

