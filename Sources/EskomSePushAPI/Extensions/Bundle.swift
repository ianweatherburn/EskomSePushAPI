//
//  Bundle.swift
//  LoadShedding
//
//  Created by Ian Weatherburn on 2023/03/21.
//

import Foundation

extension Bundle {
    func decode<T: Decodable>(_ type: T.Type, from file: String, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate, keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys) throws -> T {
        guard let url = self.url(forResource: file, withExtension: nil) else {
            throw RequestError.bundleNotFound(file)
        }

        guard let data = try? Data(contentsOf: url) else {
            throw RequestError.bundleNotFound(file)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = dateDecodingStrategy
        decoder.keyDecodingStrategy = keyDecodingStrategy

        do {
            return try decoder.decode(T.self, from: data)
        } catch DecodingError.keyNotFound(let key, let context) {
            throw RequestError.keyNotFound(file, key, context)
        } catch DecodingError.typeMismatch(_, let context) {
            throw RequestError.typeMismatch(file, context)
        } catch DecodingError.valueNotFound(let type, let context) {
            throw RequestError.valueNotFound(file, type, context)
        } catch DecodingError.dataCorrupted(_) {
            throw RequestError.dataCorrupted(file)
        } catch {
            throw RequestError.decodingError(file, error.localizedDescription)
        }
    }
}

