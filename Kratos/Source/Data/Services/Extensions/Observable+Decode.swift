//
//  Observable+Decode.swift
//  Kratos
//
//  Created by Dylan Straughan on 5/9/17.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//

import Foundation
import RxSwift

extension ObservableType where E == Any {
    
    /// Decodes a JSONObject to expected object <T>, which is returned in an observable sequence.
    /// - Important: Will throw mapping error if a specific T object is not decoded correctly. Should be used if objects are necessary to proceed.
    ///
    /// - Parameter keyPath: keypath for navigation to start the decoding process.
    /// - Returns: Observable<T> sequence.
    /// - Throws: Mapping Error is thrown if it cannot cast `Any` to `JSONObject`, or if a specific T object is not decoded correctly.
    func mapObject<T: JSONDecodable>(at keyPath: String? = nil) -> Observable<T> {
        return observeOn(SerialDispatchQueueScheduler(qos: .background))
            .flatMap { response -> Observable<T> in
                let jsonObject: JSONObject = try self.json(from: response, at: keyPath)
                let object: T = try self.decode(json: jsonObject)
                return Observable.just(object)
            }
            .observeOn(MainScheduler.instance)
    }
    
    /// Decodes an expeceted array of JSONObjects to an array of [T], which is returned in an observable sequence.
    /// - Important: Will throw mapping error if a specific T object is not decoded correctly. Should be used if objects are necessary to proceed.
    /// - Note: Will throw
    ///
    /// - Parameter keyPath: keypath for navigation to start the decoding process.
    /// - Returns: Observable<[T]> sequence.
    /// - Throws: Mapping Error is thrown if it cannot cast `Any` to `[JSONObject]`, or if a specific T object is not decoded correctly.
    func mapArray<T: JSONDecodable>(at keyPath: String? = nil ) -> Observable<[T]> {
        return observeOn(SerialDispatchQueueScheduler(qos: .background))
            .flatMap { response -> Observable<[T]> in
                let jsonArray: [JSONObject] = try self.json(from: response, at: keyPath)
                let objects = try jsonArray.map { json -> T in
                    return try self.decode(json: json)
                }
                return Observable.just(objects)
            }
            .observeOn(MainScheduler.instance)
    }
    
    
    /// Decodes an expeceted array of JSONObjects to an array of [T], which is returned in an observable sequence.
    /// - Important: Does not throw mapping error if a specific T object is not decoded correctly, it will simply omit it.
    /// - Note: Will throw mapping error if it cannot cast `Any` to `[JSONObject]`.
    ///
    /// - Parameter keyPath: keypath for navigation to start the decoding process.
    /// - Returns: Observable<[T]> sequence, with any decoding failures ommitted.
    func softMapArray<T: JSONDecodable>(at keyPath: String? = nil) -> Observable<[T]> {
        return observeOn(SerialDispatchQueueScheduler(qos: .background))
            .flatMap { response -> Observable<[T]> in
                let jsonArray: [JSONObject] = try self.json(from: response, at: keyPath)
                let objects = jsonArray.flatMap { T(json:$0) }
                return Observable.just(objects)
            }
            .observeOn(MainScheduler.instance)
    }
    
    
    /// Casts Any type to a desired T type.
    ///
    /// - Parameters:
    ///   - response: Serialized JSON used to cast to desired T Type
    ///   - keyPath: Keypath for value to be returned from JSONObject
    /// - Returns: returns desired T Type
    /// - Throws: throws if cannot cast to JSONObject, or to T type.
    func json<T>(from response: Any, at keyPath: String? = nil ) throws -> T {
        var json: Any? = nil
        
        if let keyPath = keyPath,
            let response = response as? JSONObject {
            json = response[keyPath]
        } else {
            json = response
        }
        
        if let json = json as? T {
            return json
        }
        
        throw KratosError.mappingError(type: .unexpectedValue)
    }
    
    func decode<T: JSONDecodable>(json: JSONObject) throws -> T {
        if let object = T(json: json) {
            return object
        }
        throw KratosError.mappingError(type: .failure)
    }
}
