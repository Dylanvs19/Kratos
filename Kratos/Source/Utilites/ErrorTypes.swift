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
    func handle(error: NetworkError)
}

extension ErrorPresenter where Self: UIViewController, Self: Toaster {
    func handle(error: NetworkError) {
        switch error.type {
        case .surfaceable:
            present(error: error)
        case .silent:
            break
        case .critical:
            fatalError()
        }
    }
}

enum ErrorType {
    case surfaceable
    case silent
    case critical
}

enum NetworkError: Error {
    case timeout
    case nilData
    case invalidSerialization
    case appSideError(error: [[String: String]]?)
    case invalidURL(error: [[String: String]]?)
    case duplicateUserCredentials(error: [[String: String]]?)
    case invalidCredentials(error: [[String: String]]?)
    case serverSideError(error: [[String: String]]?)
    
    var type: ErrorType {
        return .surfaceable
    }
    
    static func error(for statusCode:Int, error: [[String: String]]?) -> NetworkError? {
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

func ==(lhs: NetworkError, rhs: NetworkError) -> Bool {
    return lhs.localizedDescription == rhs.localizedDescription
}
