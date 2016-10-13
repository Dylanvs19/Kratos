//
//  String+Extensions.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/31/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import Foundation

extension String {
    
    func removeWhiteSpace() -> String {
        return stringByReplacingOccurrencesOfString(" ", withString: "")
    }
    
    func trimWhiteSpaces() -> String {
        return stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
    
    func characterCountIs(count:Int) -> Bool {
        return count == characters.count
    }
    
    func containsOnlyCharacters(in set: NSCharacterSet) -> Bool {
        
        if self.stringByTrimmingCharactersInSet(set) == "" {
            return true
        }
        return false
    }
    
    func containsCharacters(in set: NSCharacterSet) -> Bool {
        return self.characters.count == self.stringByTrimmingCharactersInSet(set).characters.count ? false : true
    }
}
