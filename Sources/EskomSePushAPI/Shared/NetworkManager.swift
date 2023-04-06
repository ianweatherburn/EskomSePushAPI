//
//  NetworkManager.swift
//  LoadShedding
//
//  Created by Ian Weatherburn on 2023/03/21.
//

import Foundation

struct Constants {
    enum EndPoint {
        static let scheme = "https"
        static let host = "developer.sepush.co.za"
        
        static let apiVersion = "/business/2.0"
        
        static let apiAllowance = "\(apiVersion)/api_allowance"
        static let status = "\(apiVersion)/status"
        static let areaInformation = "\(apiVersion)/area"
        static let areaSearch = "\(apiVersion)/areas_search"
        static let areasNearby = "\(apiVersion)/areas_nearby"
        static let topicsNearby = "\(apiVersion)/topics_nearby"
    }
    
    enum QueryParams {
        static let id = "id"
        static let test = "test"
        static let text = "text"
        static let latitude = "lat"
        static let longitude = "lon"
    }
    
    struct Authorization {
        static let token = "token"
    }
}

typealias KeyValues = [String: String]?

protocol Endpoint {
    var scheme: String { get }
    var host: String { get }
    var path: String { get }
    var components: KeyValues { get }
    var method: RequestMethod { get }
    var header: KeyValues { get }
    var body: KeyValues { get }
}

extension Endpoint {
    var scheme: String {
        return Constants.EndPoint.scheme
    }
    
    var host: String {
        return Constants.EndPoint.host
    }
}

enum RequestMethod: String {
    case delete = "DELETE"
    case get = "GET"
    case patch = "PATCH"
    case post = "POST"
    case put = "PUT"
}

protocol HTTPClient {
    // Function call syntax sendRequest(toEndpoint, forDataType, withToken)
    func sendRequest<T: Decodable>(to endpoint: Endpoint,
                                   returning responseModel: T.Type,
                                   with token: String) async throws  -> T
}

extension HTTPClient {
    func sendRequest<T: Decodable>(to endpoint: Endpoint,
                                   returning responseModel: T.Type,
                                   with token: String) async throws -> T {

        // Build the URL from components
        guard let url = buildURL(for: endpoint) else {
            throw RequestError.invalidURL("\(endpoint.scheme)://\(endpoint.host)/\(endpoint.path)")
        }
        
        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue

        // Setup the request header authentication
        request.allHTTPHeaderFields = endpoint.header
        if let _ = request.value(forHTTPHeaderField: Constants.Authorization.token) {
            request.allHTTPHeaderFields?.updateValue(token, forKey: Constants.Authorization.token)
        }
        
        // Setup the request body
        if let body = endpoint.body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let response = response as? HTTPURLResponse else {
            throw RequestError.noResponse
        }
        
        switch response.statusCode {
        case 200...299:
            guard let decodedResponse = try? JSONDecoder().decode(responseModel, from: data) else {
                throw RequestError.decode
            }
            return decodedResponse
        case 400:
            throw RequestError.badRequest
        case 403:
            throw RequestError.notAuthenticated
        case 404:
            throw RequestError.notFound(url.absoluteString)
        case 408:
            throw RequestError.requestTimeout
        case 429:
            throw RequestError.tooManyRequests
        case 500...599:
            throw RequestError.serverIssue
        default:
            throw RequestError.unexpectedStatusCode(response.statusCode)
        }
        
        // Build the full URL for this endpoint from it's constituent components, including it's queryString
        func buildURL(for endpoint: Endpoint) -> URL? {
            var components = URLComponents()
            components.scheme = endpoint.scheme
            components.host = endpoint.host
            components.path = endpoint.path
            if let queryItems = endpoint.components {
                components.setQueryItems(with: queryItems)
            }
            return components.url
        }
    }
}

enum EskomSePushEndpoint {
    case checkAllowance
    case status
    case areaInformation(areaID: String, test: Testing?)
    case areasNearby(lat: Double, lon: Double)
    case areasSearch(text: String)
    case topicsNearby(lat: Double, lon: Double)
}

extension EskomSePushEndpoint: Endpoint {
    var path: String {
        switch self {
        case .checkAllowance:
            return Constants.EndPoint.apiAllowance
        case .status:
            return Constants.EndPoint.status
        case .areaInformation(_, _):
            return Constants.EndPoint.areaInformation
        case .areasSearch(_):
            return Constants.EndPoint.areaSearch
        case .areasNearby(_, _):
            return Constants.EndPoint.areasNearby
        case .topicsNearby(_, _):
            return Constants.EndPoint.topicsNearby
        }
    }
    
    var components: KeyValues {
        switch self {
        case .checkAllowance:
            return nil
        case .status:
            return nil
        case .areaInformation(areaID: let areaID, test: let test):
            if let test {
                return [Constants.QueryParams.id: areaID, Constants.QueryParams.test: test.rawValue]
            } else {
                return [Constants.QueryParams.id: areaID]
            }
        case .areasSearch(text: let text):
            return [Constants.QueryParams.text: text]
        case .areasNearby(lat: let lat, lon: let lon):
            return [Constants.QueryParams.latitude: String(lat), Constants.QueryParams.longitude: String(lon)]
        case .topicsNearby(lat: let lat, lon: let lon):
            return [Constants.QueryParams.latitude: String(lat), Constants.QueryParams.longitude: String(lon)]
        }
    }
    
    var method: RequestMethod {
        switch self {
        case .checkAllowance,
             .status,
             .areaInformation(_, _),
             .areasNearby(_, _),
             .areasSearch(_),
             .topicsNearby(_, _):
            return .get
        }
    }
    
    var header: KeyValues {
        switch self {
        case .checkAllowance,
             .status,
             .areaInformation(_, _),
             .areasNearby(_, _),
             .areasSearch(_),
             .topicsNearby(_, _):
            return [
                Constants.Authorization.token: "",
                "Content-Type": "application/json;charset=utf-8"
            ]
        }
    }
    
    var body: KeyValues {
        switch self {
        case .checkAllowance,
             .status,
             .areaInformation(_, _),
             .areasNearby(_, _),
             .areasSearch(_),
             .topicsNearby(_, _):
            return nil
        }
    }
}

public enum Testing: String {
    // Include the &test=current or &test=future to get SAMPLE data returned in the events.
    // current will return a loadshedding event which is occurring right now,
    // and future will return an event starting on the next hour.
    case current = "current"
    case future = "future"
}
