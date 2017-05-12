//
//  Observable+Decode.swift
//  Kratos
//
//  Created by Dylan Straughan on 5/9/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import RxSwift

extension ObservableType where E == Any {
    
    func mapObject<T: Decodable>(at keyPath: String? = nil) -> Observable<T> {
        return observeOn(SerialDispatchQueueScheduler(qos: .background))
            .flatMap { response -> Observable<T> in
                let jsonObject: JSONObject = try self.json(from: response, at: keyPath)
                let object: T = try self.decode(json: jsonObject)
                return Observable.just(object)
            }
            .observeOn(MainScheduler.instance)
    }
    
    func mapArray<T: Decodable>(at keyPath: String? = nil ) -> Observable<[T]> {
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
    
    func decode<T: Decodable>(json: JSONObject) throws -> T {
        if let object = T(json: json) {
            return object
        }
        throw KratosError.mappingError(type: .failure)
    }
}
