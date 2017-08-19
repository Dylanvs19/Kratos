//
//  Contstants.swift
//  Kratos
//
//  Created by Dylan Straughan on 8/9/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import Foundation

enum Constant: String {
    
    case exploreTitle = "On The Floor"
    case exploreSenateButtonTitle = "Senate"
    case exploreHouseButtonTitle = "House"
}

func localize(_ constant: Constant) -> String {
    return constant.rawValue
}
