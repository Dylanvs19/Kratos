//
//  String+Extensions.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/31/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
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
        if let first = self.characters.first {
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
    
    /// Reformats Statuses that come back from API.
    /// - Note: Handles common cases and then defaults to removing characters and localizedCapitalization. 
    var cleanStatus: String {
        switch self {
        case "PASS_OVER:HOUSE": return "Passed Over House"
        case "PASS_OVER:SENATE": return "Passed Over Senate"
        case "ENACTED:SIGNED": return "Signed into Law"
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
    
    
    /// Validates string based on inputValidation type passed as parameter
    ///
    /// - Parameter inputValidation: inputValidation type
    /// - Returns: bool indicating whether string is valid based on inputValidation type
    func isValid(for inputValidation: InputValidation) -> Bool {
        switch inputValidation {
        case .email:
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
            let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
            return emailTest.evaluate(with: self)
        case .address,
             .city:
            return self.containsOnlyCharacters(in: .letterPunctuationSet) && self != "" ? true : false
        case .state:
            let sanitizedState = self.removeWhiteSpace()
            return State(rawValue: sanitizedState) != nil && sanitizedState.characters.count == 2
        case .zipcode:
            let sanitizedzipcode = self.removeWhiteSpace()
            return sanitizedzipcode.containsOnlyCharacters(in: CharacterSet.decimalDigits)
                && sanitizedzipcode.characterCountIs(5) ? true : false
        case .password:
            return self.characters.count > 7
        }
    }
}
