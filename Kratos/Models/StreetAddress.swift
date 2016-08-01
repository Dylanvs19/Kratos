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
    
    
    static func dictionaryFormat(streetAddress: StreetAddress) -> [String : [String:String]] {
        if let
            street = streetAddress.street,
            city = streetAddress.city,
            state = streetAddress.state,
            zipCode = streetAddress.zipCode {
            
            let returnDictionary = [ "address" : [ "street" : street,
                                                   "city" : city,
                                                   "state" : state,
                                                   "zipCode" : zipCode ]
                                    ]
            
            return returnDictionary
            
        } else {
            fatalError("Could not obtain Street Address")
        }
    }
}