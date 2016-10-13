//
//  InputValidation.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/31/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import Foundation

struct InputValidation {
    
    static func validateAddress(address: String?) -> Bool {
        guard let address = address else { return false }
        return address.containsOnlyCharacters(in: .letterPunctuationSet) && address != "" ? true : false
    }
    
    static func validateCity(city: String?) -> Bool {
        guard let city = city else { return false }
        return city.containsOnlyCharacters(in: .letterPunctuationSet) && city != "" ? true : false
    }
    
    static func validateState(state:String?) -> Bool {
        guard let state = state else { return false }
        let sanitizedState = state.removeWhiteSpace()
        return Constants.stateSet.containsObject(sanitizedState.uppercaseString)
    }
    
    static func validateZipCode(zipcode: String?) -> Bool {
        guard let zipcode = zipcode else { return false }
        let sanitizedzipcode = zipcode.removeWhiteSpace()
        return sanitizedzipcode.containsOnlyCharacters(in: NSCharacterSet.decimalDigitCharacterSet())
            && sanitizedzipcode.characterCountIs(5) ? true : false
    }
    
    static func validatePhoneNumber(phoneNumber: String?) -> Bool {
        guard let phoneNumber = phoneNumber else { return false }
        let sanitizedzipcode = phoneNumber.removeWhiteSpace()
        return sanitizedzipcode.containsOnlyCharacters(in: NSCharacterSet.decimalDigitCharacterSet())
            && sanitizedzipcode.characterCountIs(10) ? true : false
    }
    
    static func validatePasswordConfirmation(password: String?, passwordConfirmation: String?) -> Bool {
        guard let password = password,
              let passwordConfirmation = passwordConfirmation else { return false }
        return password == passwordConfirmation ? true : false
    }
    
    static func validatePassword(password: String?) -> Bool {
        guard let password = password else { return false }
        if password.characters.count > 7 &&
        password.containsCharacters(in: NSCharacterSet.decimalDigitCharacterSet()) &&
            password.containsCharacters(in: NSCharacterSet.letterCharacterSet()) {
            return true
        } else {
            return false 
        }
    }
}
