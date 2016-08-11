//
//  StreetAddress.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/31/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import Foundation

struct StreetAddress {
    
    var street: String?
    var city: String?
    var state: String?
    var zipCode: String?
    var district: Int?
    
    
    var dictionaryFormat: [String: String] {
        var returnDictionary: [String: String] = [:]
        if let
            street = self.street,
            city = self.city,
            state = self.state,
            zipCode = self.zipCode {
            
            returnDictionary = [ "address" : "\(street) \(city) \(state) \(zipCode)" ]
        }
        return returnDictionary
    }
}