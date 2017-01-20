//
//  InputValidation.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/31/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import Foundation

struct InputValidation {
    
    static func validateEmail(_ email: String?) -> Bool {
        guard let email = email else { return false }
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    static func validateAddress(_ address: String?) -> Bool {
        guard let address = address else { return false }
        return address.containsOnlyCharacters(in: .letterPunctuationSet) && address != "" ? true : false
    }
    
    static func validateCity(_ city: String?) -> Bool {
        guard let city = city else { return false }
        return city.containsOnlyCharacters(in: .letterPunctuationSet) && city != "" ? true : false
    }
    
    static func validateState(_ state:String?) -> Bool {
        guard let state = state else { return false }
        let sanitizedState = state.removeWhiteSpace()
        return Constants.stateSet.contains(sanitizedState.uppercased())
    }
    
    static func validateZipCode(_ zipcode: String?) -> Bool {
        guard let zipcode = zipcode else { return false }
        let sanitizedzipcode = zipcode.removeWhiteSpace()
        return sanitizedzipcode.containsOnlyCharacters(in: CharacterSet.decimalDigits)
            && sanitizedzipcode.characterCountIs(5) ? true : false
    }
    
    static func validatePhoneNumber(_ phoneNumber: String?) -> Bool {
        guard let phoneNumber = phoneNumber else { return false }
        let sanitizedzipcode = phoneNumber.removeWhiteSpace()
        return sanitizedzipcode.containsOnlyCharacters(in: CharacterSet.decimalDigits)
            && sanitizedzipcode.characterCountIs(10) ? true : false
    }
    
    static func validatePasswordConfirmation(_ password: String?, passwordConfirmation: String?) -> Bool {
        guard let password = password,
              let passwordConfirmation = passwordConfirmation else { return false }
        return password == passwordConfirmation ? true : false
    }
    
    static func validatePassword(_ password: String?) -> Bool {
        guard let password = password else { return false }
        if password.characters.count > 7 &&
        password.containsCharacters(in: CharacterSet.decimalDigits) &&
            password.containsCharacters(in: CharacterSet.letters) {
            return true
        } else {
            return false 
        }
    }
}
