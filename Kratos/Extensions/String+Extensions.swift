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
    
    /// Method that returns an optional date from a dateString. Through a series of if-lets it fallback on different date formats attempting to return a valid date from the dateString. If no date formats return back a valid string, the method will return back nil. Current date formats being tested are:
    /// - "YYYY-MM-dd"
    /// - "yyyy-MM-dd'T'HH:mm:ss"
    func stringToDate() -> Date? {
        if let holdDate = DateFormatter.billDateFormatter.date(from: self) {
            return holdDate
        }
        if let holdDate = DateFormatter.longDateFormatter.date(from: self) {
            return holdDate
        }
        return nil
    }
}
