//
//  ErrorTypes.swift
//  Kratos
//
//  Created by Dylan Straughan on 12/20/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import Foundation
import UIKit

enum KratosError: Error {
    case unknown
    case server(error: Error, statusCode: Int)
    case mappingError(type: MappingError)
    case authError(error: AuthenticationError)
    case requestError(title: String, message: String, statusCode: Int)
    
    static func error(from json: JSONObject, statusCode: Int) -> KratosError {
        guard let errors = json["errors"] as? [[String: String]],
              let first = errors.first?.first else { return KratosError.unknown }
        return .requestError(title: first.key, message: first.value, statusCode: statusCode)
    }
    
    static func error(from error: Error, statusCode: Int) -> KratosError {
        return .server(error: error, statusCode: statusCode)
    }
}

func ==(lhs: KratosError, rhs: KratosError) -> Bool {
    switch  (lhs, rhs) {
    case (.unknown, .unknown),
         (.server, .server),
         (.mappingError, .mappingError),
         (.authError, .authError),
         (.requestError, .requestError):
        return true
    default:
        return false
    }
}
