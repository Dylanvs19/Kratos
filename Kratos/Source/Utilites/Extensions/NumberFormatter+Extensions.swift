//
//  NumberFormatter+Extensions.swift
//  Kratos
//
//  Created by Dylan Straughan on 8/27/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation

extension NumberFormatter {
    
    static var ordinal: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter
    }
}