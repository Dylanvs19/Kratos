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
        return replacingOccurrences(of: " ", with: "")
    }
    
    func trimWhiteSpaces() -> String {
        return trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    func characterCountIs(_ count:Int) -> Bool {
        return count == characters.count
    }
    
    func containsOnlyCharacters(in set: CharacterSet) -> Bool {
        
        if self.trimmingCharacters(in: set) == "" {
            return true
        }
        return false
    }
    
    func containsCharacters(in set: CharacterSet) -> Bool {
        return self.characters.count == self.trimmingCharacters(in: set).characters.count ? false : true
    }
}
