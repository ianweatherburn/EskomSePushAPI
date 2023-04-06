//
//  String.swift
//  LoadShedding
//
//  Created by Ian Weatherburn on 2023/03/21.
//

import Foundation

extension String {
    func ISO8601Date(style: ISO8601DateFormatter.Options = [.withInternetDateTime, .withFractionalSeconds],
                     timeZone: TimeZone = .current) -> Date {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = style
        var newDate: Date
        
        if let date = formatter.date(from: self) {
            newDate = date
        } else {
            // Some of the JSON date/time stamps do not have fractional seconds
            formatter.formatOptions = [.withInternetDateTime]
            if let date = formatter.date(from: self) {
               newDate = date
            } else {
                newDate = Date()
            }
        }
        return newDate
    }
}

