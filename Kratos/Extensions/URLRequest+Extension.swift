//
//  NSMutableURLRequest+Extension.swift
//  Kratos
//
//  Created by Dylan Straughan on 9/28/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import Foundation

enum HTTPMethod: String {
    case post = "POST"
    case get = "GET"
    case put = "PUT"
    case delete = "DELETE"
}

extension URLRequest {

    ///Convenience Method that sets major components of initialized NSMutableURLRequest and throws error if body cannot be serialized into JSON
    /// - parameter - url: NSURL - URL
    /// - parameter - requestType: URLRequestType - HTTPMethod
    /// - parameter - body: [String: AnyObject]? - HTTPBody
    init(url: URL, requestType: HTTPMethod, body: [String: Any]? = nil, addToken: Bool = true) {
        //self.url = url
        self.init(url: url)
        httpMethod = requestType.rawValue
        addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = KeychainManager.fetchToken(), addToken {
            addValue("Bearer \(token)", forHTTPHeaderField:"Authorization")
        }
        if let body = body {
            httpBody = try? JSONSerialization.data(withJSONObject: body, options: [.prettyPrinted])
        }
    }
}
