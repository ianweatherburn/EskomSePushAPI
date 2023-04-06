//
//  File.swift
//  
//
//  Created by Ian Weatherburn on 2023/04/05.
//

import Foundation

public enum RequestError: Error {
    case decode
    case invalidURL(String)
    case noResponse
    case badRequest
    case notAuthenticated
    case notFound(String)
    case requestTimeout
    case tooManyRequests
    case serverIssue
    case unexpectedStatusCode(Int)
    
    case bundleNotFound(String)
    case keyNotFound(String, CodingKey, DecodingError.Context)
    case typeMismatch(String, DecodingError.Context)
    case valueNotFound(String, Any.Type, DecodingError.Context)
    case dataCorrupted(String)
    case decodingError(String, String)
    
    case unknown
    
    // https://documenter.getpostman.com/view/1296288/UzQuNk3E#responses:~:text=%F0%9F%9A%A8%20Important-,Responses,-Authentication
    var localizedDescription: String {
        switch self {
        case .decode:
            return "Decode error"
        case .invalidURL(let url):
            return "Unknwon endpoint \(url)"
        case .noResponse:
            return "No response"
        case .badRequest: // 400
            return "Bad request"
        case .notAuthenticated: // 403
            return "Not authenticated. Token is invalid or disabled"
        case .notFound(let url): // 404
            return "\(url) not found"
        case .requestTimeout: // 408
            return "Request timeout. (Try again, gently)"
        case .tooManyRequests: // 429
            return "Too many requests. (Token quota exceeded)"
        case .serverIssue: // 5xx
            return "Server Issue. Please report to your administrator"
        case .unexpectedStatusCode(let statusCode):
            return "Server returned an unexpected status code of \(statusCode)"

        case .bundleNotFound(let file):
            return "Failed to locate \(file) in bundle."
       case .keyNotFound(let file, let key, let context):
            return "Failed to decode \(file) from bundle due to missing key '\(key.stringValue)' not found – \(context.debugDescription)"
        case .typeMismatch(let file, let context):
            return "Failed to decode \(file) from bundle due to type mismatch – \(context.debugDescription)"
        case .valueNotFound(let file, let type, let context):
            return "Failed to decode \(file) from bundle due to missing \(type) value – \(context.debugDescription)"
        case .dataCorrupted(let file):
            return "Failed to decode \(file) from bundle because it appears to be invalid JSON"
        case .decodingError(let file, let description):
            return "Failed to decode \(file) from bundle: \(description)"

        default:
            return "Unknwon error"
        }
    }
}
