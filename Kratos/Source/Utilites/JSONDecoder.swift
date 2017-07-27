//
//  JSONDecoder.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/26/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
/// Errors that may occur while decoding JSON.
enum MappingError: Error {
    /// Binary data does not match expected JSON type.
    case unexpectedValue
    /// JSON failed to map into a `Decodable` type.
    case failure
//    case mappedToError(ServerError)
}

/// A closed set of functions which decode binary data to JSON and JSON into `Decodable` types.
enum JSONDecoder {
    /// Converts a response object into JSON of an expected type. If a keypath is provided, converts the value found at
    /// that keypath to the expected type.
    ///
    /// - Parameters:
    ///   - response: The response to convert into JSON.
    ///   - keyPath: The keypath of the response to convert. By default, nil.
    /// - Returns: The converted JSON if the conversion occurred without error.
    /// - Throws: `MappingError.unexpectedValue` if the conversion fails.
    static func json<T>(from response: Any, at keyPath: String? = nil) throws -> T {
        var json: Any? = nil
        
        if let keypath = keyPath, let response = response as? JSONObject {
            // If a keypath was provided, and the response is of type JSONObject
            // unpack the json from that value
            json = response[keypath]
        } else {
            json = response
        }
        
        if let json = json as? T {
            return json
        }
        
        throw MappingError.unexpectedValue
    }
    
    /// Converts a JSON object into a `Decodable` type.
    ///
    /// - Parameter json: The JSON to convert into a type.
    /// - Returns: The decoded object if the decoding occurred without error.
    /// - Throws: `MappingError.mappingFailed` if the conversion failed.
    static func decode<T: Decodable>(json: JSONObject) throws -> T {
        if let object = T(json: json) {
            return object
        }
//        if let error = ServerError(json: json) {
//            throw MappingError.mappedToError(error)
//        }
        throw MappingError.failure
    }
    
    /// Converts a JSON String into a `Decodable` type.
    ///
    /// - Parameter json: The JSON to convert into a type.
    /// - Returns: The decoded object if the decoding occurred without error.
    /// - Throws: `MappingError.mappingFailed` if the conversion failed.
    static func decode<T: Decodable>(jsonString: String) throws -> T {
        
        if let data = jsonString.data(using: .utf8) {
            let jsonObj = try JSONSerialization.jsonObject(with: data, options: .allowFragments )
            if let json = jsonObj as? JSONObject {
                if let object = T(json: json) {
                    return object
                }
            }
        }
        throw MappingError.failure
    }
    
    static func decode<T: Decodable>(jsonString: String) throws -> [T] {
        
        if let data = jsonString.data(using: .utf8) {
            let jsonObj = try JSONSerialization.jsonObject(with: data, options: .allowFragments )
            if let json = jsonObj as? [JSONObject] {
                
                let results: [T] = try json.map { json in
                    if let object = T(json: json) {
                        return object
                    }
                    throw MappingError.failure
                }
                return results
            }
        }
        throw MappingError.failure
    }
    
}
