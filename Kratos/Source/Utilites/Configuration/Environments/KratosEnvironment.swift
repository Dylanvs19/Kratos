//
//  KratosEnvironment.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/26/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation

enum KratosEnvironment {
    case staging
    case production
}

extension KratosEnvironment {
    
    var url: String {
        switch self {
        case .staging:
            return "https://kratos.site/api"
        case .production:
            return "https://kratos.site/api"
        }
    }
    
    var clientId: String {
        switch self {
        case .staging:
            return ""
        case .production:
            return ""
        }
    }
    
    var clientSecret: String {
        switch self {
        case .staging:
            return ""
        case .production:
            return ""
        }
    }
}
