//
//  NSData+Extensions.swift
//  Kratos
//
//  Created by Dylan Straughan on 5/5/17.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//

import Foundation
import RxSwift

extension Data {
    
    func toJSON() -> Any? {
        return try? JSONSerialization.jsonObject(with: self, options: [])
    }
    
    
}
