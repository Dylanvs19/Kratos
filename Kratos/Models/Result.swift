//
//  Result.swift
//  Kratos
//
//  Created by Dylan Straughan on 3/31/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import UIKit

enum Result<Type> {
    case some(Type)
    case error(NetworkError)
    
    func flatMap<NewType>(_ mapper: (Type) -> Result<NewType>) -> Result<NewType> {
        switch self {
        case .some(let value):
            return mapper(value)
        case .error(let error):
            return .error(error)
            
        }
    }
}
