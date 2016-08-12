//
//  NSCharacterSet+Extensions.swift
//  Kratos
//
//  Created by Dylan Straughan on 8/1/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import Foundation

extension NSCharacterSet {
    
    static var letterPunctuationSet: NSCharacterSet {
        let set = NSMutableCharacterSet.alphanumericCharacterSet()
        set.formUnionWithCharacterSet(NSCharacterSet.punctuationCharacterSet())
        set.formUnionWithCharacterSet(NSCharacterSet(charactersInString: " "))
        return set
    }
}