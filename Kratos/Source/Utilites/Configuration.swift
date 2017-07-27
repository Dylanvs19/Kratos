//
//  Configuration.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/26/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation

enum Configuration {
    case staging
    case production
}

extension Configuration {
    
    private static var `static`: Configuration {
        #if STAGING
            return .staging
        #endif
        #if PRODUCTION
            return .production
        #endif
        return .staging
    }
    
    static var kratos: KratosEnvironment {
        switch Configuration.static {
        case .staging:
            return .staging
        case .production:
            return .production
        }
    }
    
    static var cacheExpiration: TimeInterval {
        switch Configuration.static {
        case .staging:
            return 10
        case .production:
            return 300
        }
    }
}
