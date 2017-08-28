//
//  Int+Extension.swift
//  Kratos
//
//  Created by Dylan Straughan on 8/27/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation

extension Int {
    
    var ordinal: String {
        return NumberFormatter.ordinal.string(from: NSNumber(value: self)) ?? ""
    }
}
