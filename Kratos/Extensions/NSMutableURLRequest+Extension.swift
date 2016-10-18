//
//  NSMutableURLRequest+Extension.swift
//  Kratos
//
//  Created by Dylan Straughan on 9/28/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import Foundation

enum URLRequestType: String {
    case post = "POST"
    case get = "GET"
}

extension NSMutableURLRequest {

    ///Convenience Method that sets major components of initialized NSMutableURLRequest and throws error if body cannot be serialized into JSON
    ///@param - url: NSURL - URL
    ///@param - requestType: URLRequestType - HTTPMethod
    ///@param - body: [String: AnyObject]? - HTTPBody
    func setAuthentication(url: NSURL, requestType: URLRequestType, body: [String: AnyObject]?) throws {
        URL = url
        HTTPMethod = requestType.rawValue
        addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = KeychainManager.fetchToken() {
            addValue("Bearer \(token)", forHTTPHeaderField:"Authorization")
        }
        if let body = body {
            do {
                let jsonData = try NSJSONSerialization.dataWithJSONObject(body, options: [.PrettyPrinted])
                HTTPBody = jsonData
            } catch let error as NSError {
                throw error
            }
        }
    }
    
}
