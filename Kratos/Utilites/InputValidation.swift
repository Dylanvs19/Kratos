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
        
        let sanitizedAddress = address.removeWhiteSpace()
        
        if sanitizedAddress.containsOnlyCharacters(in: NSCharacterSet.alphanumericCharacterSet()) {
            return true
        }
        return false
    }
    
    static func validateCity(city: String?) -> Bool {
        guard let city = city else { return false }
        
        let sanitizedCity = city.removeWhiteSpace()
        
        if sanitizedCity.containsOnlyCharacters(in: NSCharacterSet.alphanumericCharacterSet()) {
            return true
        }
        return false
    }
    
    static func validateState(state:String?) -> Bool {
        guard let state = state else { return false }
        
        let sanitizedState = state.removeWhiteSpace()
        
        if sanitizedState.containsOnlyCharacters(in: NSCharacterSet.alphanumericCharacterSet()) && sanitizedState.characterCountIs(2){
            return true
        }
        return false
    }
    
    static func validateZipCode(zipcode: String?) -> Bool {
        guard let zipcode = zipcode else { return false }
        
        let sanitizedzipcode = zipcode.removeWhiteSpace()
        
        if sanitizedzipcode.containsOnlyCharacters(in: NSCharacterSet.decimalDigitCharacterSet()) && sanitizedzipcode.characterCountIs(5){
            return true
        }
        return false
    }
    
}