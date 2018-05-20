//
//  String+Extensions.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/31/16.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//

import Foundation

enum InputValidation {
    case email
    case address
    case city
    case state
    case zipcode
    case password
}

extension String {
    
    var firstLetter: String {
        if let first = self.first {
            return String(first)
        }
        return ""
    }
    
    func removeWhiteSpace() -> String {
        return replacingOccurrences(of: " ", with: "")
    }
    
    func trimWhiteSpaces() -> String {
        return trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    var digits: String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()
    }
    
    func characterCountIs(_ count:Int) -> Bool {
        return count == self.count
    }
    
    func containsOnlyCharacters(in set: CharacterSet) -> Bool {
        return self.trimmingCharacters(in: set) == ""
    }
    
    func containsCharacters(in set: CharacterSet) -> Bool {
        return self.count == self.trimmingCharacters(in: set).count ? false : true
    }
    
    /// Reformats Statuses that come back from API.
    /// - Note: Handles common cases and then defaults to removing characters and localizedCapitalization. 
    var cleanStatus: String {
        switch self {
        case "PASS_OVER:HOUSE": return "Passed Over House"
        case "PASS_OVER:SENATE": return "Passed Over Senate"
        case "ENACTED:SIGNED": return "Signed"
        case "REPORTED": return "Reported"
        case "REFFERED": return "Reffered"
        case "PASSED:CONCURRENTRES": return "Passed Concurrent Resolution"
        case "PASS_BACK:SENATE": return "Passed Back to Senate"
        default:
            let whiteSpaced = self.replacingOccurrences(of: ":", with: " ").replacingOccurrences(of: "_", with: " ")
            return whiteSpaced.localizedCapitalized
        }
    }
    
    /// Method that returns an optional date from a dateString. Through a series of if-lets it fallback on different date formats attempting to return a valid date from the dateString. If no date formats return back a valid string, the method will return back nil. Current date formats being tested are:
    /// - "YYYY-MM-dd"
    /// - "yyyy-MM-dd'T'HH:mm:ss"
    /// - "yyyy-MM-dd'T'HH:mm:ssZZZZ"
    /// - "MMM d, yyyy"
    var date: Date? {
        if let holdDate = DateFormatter.bill.date(from: self) {
            return holdDate
        }
        if let holdDate = DateFormatter.long.date(from: self) {
            return holdDate
        }
        if let holdDate = DateFormatter.utc.date(from: self) {
            return holdDate
        }
        if let holdDate = DateFormatter.presentation.date(from: self) {
            return holdDate
        }
        return nil
    }
    
    var isValidZipcode: Bool {
        let sanitizedzipcode = self.removeWhiteSpace()
        return sanitizedzipcode.containsOnlyCharacters(in: CharacterSet.decimalDigits)
            && sanitizedzipcode.characterCountIs(5)
    }
    
    var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    var isValidState: Bool {
        let sanitizedState = self.removeWhiteSpace()
        return State(rawValue: sanitizedState) != nil && sanitizedState.count == 2
    }
    
    var isValidPassword: Bool {
        return self.count > 7
    }
}
