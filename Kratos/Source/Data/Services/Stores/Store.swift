//
//  Store.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/26/17.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//

import Foundation
import AwesomeCache

class Store {
    
    /// An instance of `Cache` to store Presistent values
    fileprivate static let cache: Cache<NSString> = {
        do {
            if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let cacheDirectory = url.appendingPathComponent("Kratos.cache")
                return try Cache(name: "localCache", directory: cacheDirectory)
            }
            return try Cache(name: "localCache")
        } catch {
            fatalError("Unable to create cache.")
        }
    }()
    
    static func fetch<T: JSONDecodable>(_ cacheKey: String) -> T? {
        
        if  let jsonStr = cache.object(forKey: cacheKey),
            let model: T = try? JSONDecoder.decode(jsonString: jsonStr as String) {
            return model
        }
        return nil
    }
    
    static func fetch<T: JSONDecodable>(_ cacheKey: String) -> [T]? {
        
        if  let jsonStr = cache.object(forKey: cacheKey),
            let model: [T] = try? JSONDecoder.decode(jsonString: jsonStr as String) {
            return model
        }
        return nil
    }
    
    static func shelve<T: JSONEncodable>(_ object: T, key: String) {
        let dict = object.toJson()
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            if let string = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue) {
                cache.setObject(string, forKey: key)
            }
        } catch {
            print (error)
        }
    }
    
    static func shelve<T: JSONEncodable>(_ objects: [T], key: String) {
        let array = objects.map { object in
            return object.toJson()
        }
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: array, options: .prettyPrinted)
            if let string = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue) {
                cache.setObject(string, forKey: key)
            }
        } catch {
            print (error)
        }
    }
    
    static func remove(_ cacheKey: String) {
        cache.removeObject(forKey: cacheKey)
    }
}

extension Bool:JSONEncodable, JSONDecodable {
    init?(json: JSONObject) {
        self.init( json["value"] as? String == "true")
    }
    
    func toJson() -> JSONObject {
        return ["value": self ? "true" : "false"]
    }
}

extension Int: JSONEncodable, JSONDecodable {
    init?(json: JSONObject) {
        if let jvalue = json["value"] as? Int {
            self.init(jvalue)
        } else {
            return nil
        }
    }
    
    func toJson() -> JSONObject {
        return ["value": self ]
    }
}

extension String: JSONEncodable, JSONDecodable {
    init?(json: JSONObject) {
        if let jvalue = json["value"] as? String {
            self.init(jvalue)
        } else {
            return nil
        }
    }
    
    func toJson() -> JSONObject {
        return ["value": self ]
    }
}

extension Date: JSONEncodable, JSONDecodable {
    init?(json: JSONObject) {
        if let jvalue = json["value"] as? Double {
            self.init(timeIntervalSince1970: jvalue )
        } else {
            return nil
        }
    }
    
    func toJson() -> JSONObject {
        return ["value": self.timeIntervalSince1970 ]
    }
}
