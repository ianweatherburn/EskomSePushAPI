//
//  CheckAllowance.swift
//  LoadShedding
//
//  Created by Ian Weatherburn on 2023/03/21.
//

import Foundation

protocol AllowanceServiceable {
    func checkAllowance(with token: String) async throws -> CheckAllowance
}

struct AllowanceService: HTTPClient, AllowanceServiceable {
    func checkAllowance(with token: String) async throws -> CheckAllowance {
        return try await sendRequest(to: EskomSePushEndpoint.checkAllowance,
                                     returning: CheckAllowance.self,
                                     with: token)
    }
}

public struct CheckAllowance: Decodable {
    let allowance: Allowance
}

public struct Allowance: Decodable {
    let count: Int
    let limit: Int
    let type: String
}
