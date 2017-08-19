//
//  InputValidation.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/31/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import Foundation


enum InputValidation {
    case email(email: String?)
    case address(address: String?)
    case city(city: String?)
    case state(state: String?)
    case zipcode(zipcode: String?)
    case phone(phone: String?)
    case password(password: String?)
    
    var isValid: Bool {
        switch self {
        case .email(let email):
            guard let email = email else { return false }
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
            let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
            return emailTest.evaluate(with: email)
            
        case .address(let string),
             .city(let string):
            guard let string = string else { return false }
            return string.containsOnlyCharacters(in: .letterPunctuationSet) && string != "" ? true : false
            
        case .state(let state):
            guard let state = state else { return false }
            let sanitizedState = state.removeWhiteSpace()
            return State(rawValue: sanitizedState) != nil && sanitizedState.characters.count == 2
            
        case .zipcode(let zipcode):
            guard let zipcode = zipcode else { return false }
            let sanitizedzipcode = zipcode.removeWhiteSpace()
            return sanitizedzipcode.containsOnlyCharacters(in: CharacterSet.decimalDigits)
                && sanitizedzipcode.characterCountIs(5) ? true : false
            
        case .phone(let phone):
            guard let phone = phone else { return false }
            let sanitizedphoneNumber = phone.removeWhiteSpace().replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: "-", with: "")
            return sanitizedphoneNumber.characterCountIs(10) && !sanitizedphoneNumber.containsCharacters(in: CharacterSet.decimalDigits.inverted) ? true : false
            
        case .password(let password):
            guard let password = password else { return false }
            return password.characters.count > 7
        }
    }
}
