//
//  ErrorTypes.swift
//  Kratos
//
//  Created by Dylan Straughan on 12/20/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import Foundation

enum NetworkError: String, Error {
    case timeout = "Connection has timed out"
    case invalidURL = "Invalid endpoint or parameters"
    case invalidSerialization = "Objects could not be serialized correctly"
    case invalidAccount = "Account already exists at this address."
    case appSideError = "Networking Error from Application Side"
    case serverSideError = "Server Side Error"
    case nilData = "Data value is nil"
    
    static func error(for statusCode:Int) -> NetworkError? {
        switch statusCode {
        case 200...299:
            return nil
        case 404:
            return .invalidURL
        case 403:
            return .invalidAccount
        case 400...499:
            return .appSideError
        case 500...599:
            return .serverSideError
        default:
            return nil
        }
    }
}
