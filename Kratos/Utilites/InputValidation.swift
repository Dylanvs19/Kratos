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
        return stateSet.containsObject(sanitizedState.uppercaseString)
    }
    
    static func validateZipCode(zipcode: String?) -> Bool {
        guard let zipcode = zipcode else { return false }
        let sanitizedzipcode = zipcode.removeWhiteSpace()
        return sanitizedzipcode.containsOnlyCharacters(in: NSCharacterSet.decimalDigitCharacterSet())
            && sanitizedzipcode.characterCountIs(5) ? true : false
    }
    
    private static let stateSet = NSSet(array: [
        "AL",
        "AK",
        "AS",
        "AZ",
        "AR",
        "CA",
        "CO",
        "CT",
        "DE",
        "DC",
        "FM",
        "FL",
        "GA",
        "GU",
        "HI",
        "ID",
        "IL",
        "IN",
        "IA",
        "KS",
        "KY",
        "LA",
        "ME",
        "MH",
        "MD",
        "MA",
        "MI",
        "MN",
        "MS",
        "MO",
        "MT",
        "NE",
        "NV",
        "NH",
        "NJ",
        "NM",
        "NY",
        "NC",
        "ND",
        "MP",
        "OH",
        "OK",
        "OR",
        "PW",
        "PA",
        "PR",
        "RI",
        "SC",
        "SD",
        "TN",
        "TX",
        "UT",
        "VT",
        "VI",
        "VA",
        "WA",
        "WV",
        "WI",
        "WY",
    ])
}