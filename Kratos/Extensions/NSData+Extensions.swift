//
//  NSData+Extensions.swift
//  Kratos
//
//  Created by Dylan Straughan on 5/5/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation

extension Data {
    
    func toJSON() -> Any? {
        return try? JSONSerialization.jsonObject(with: self, options: [])
    }
}
