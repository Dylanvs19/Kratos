//
//  NSCharacterSet+Extensions.swift
//  Kratos
//
//  Created by Dylan Straughan on 8/1/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import Foundation

extension CharacterSet {
    
    static var letterPunctuationSet: CharacterSet {
        let set = NSMutableCharacterSet.alphanumeric()
        set.formUnion(with: CharacterSet.punctuationCharacters)
        set.formUnion(with: CharacterSet(charactersIn: " "))
        return set as CharacterSet
    }
    
    static var numbers: CharacterSet {
        let set = NSMutableCharacterSet(charactersIn: "1234567890")
        return set as CharacterSet
    }

}
