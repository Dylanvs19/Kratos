//
//  ErrorTypes.swift
//  Kratos
//
//  Created by Dylan Straughan on 12/20/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import Foundation
import UIKit

protocol ErrorPresenter {
    func handle(error: KratosError)
}

extension ErrorPresenter where Self: UIViewController, Self: Toaster {
    func handle(error: KratosError) {
        switch error.type {
        case .surfaceable:
            present(error: error)
        case .silent:
            print("\(error)")
        case .critical:
            fatalError("\(error)")
        }
    }
}

enum ErrorType {
    case surfaceable(style: ErrorPresentationStyle)
    case silent
    case critical
    
    var hashValue: Int {
        switch self {
        case .surfaceable:
            return 1
        case .silent:
            return 2
        case .critical:
            return 3
        }
    }
}

enum ErrorPresentationStyle {
    case toaster
    case alert
}

enum KratosError: Error {
    case timeout
    case nilData
    case invalidSerialization
    case unknown
    case mappingError(type: MappingError)
    case nonHTTPResponse(response: URLResponse?)
    case appSideError(error: [[String: String]]?)
    case invalidURL(error: [[String: String]]?)
    case duplicateUserCredentials(error: [[String: String]]?)
    case invalidCredentials(error: [[String: String]]?)
    case serverSideError(error: [[String: String]]?)
    
    var type: ErrorType {
        switch self {
        case .nilData:
            return .silent
        default:
            return .surfaceable(style: .toaster)
        }
    }
    
    static func error(for statusCode:Int, error: [[String: String]]?) -> KratosError? {
        switch statusCode {
        case 200...299:
            return nil
        case 404:
            return .invalidURL(error: error)
        case 403:
            return .invalidCredentials(error: error)
        case 422:
            return .duplicateUserCredentials(error: error)
        case 400...499:
            return .appSideError(error: error)
        case 500...599:
            return .serverSideError(error: error)
        default:
            return nil
        }
    }
}

func ==(lhs: KratosError, rhs: KratosError) -> Bool {
    return lhs.localizedDescription == rhs.localizedDescription
}

func ==(lhs: ErrorType, rhs: ErrorType) -> Bool {
    return lhs.hashValue == rhs.hashValue
}
