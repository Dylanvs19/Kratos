//
//  User.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/31/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import Foundation

struct User {
    var firstName: String
    var lastName: String
    var phoneNumber: Int
    var streetAddress: StreetAddress
    var district: Int?
    var id: Int?
    
    init(firstName: String, lastName: String, phoneNumber: Int, streetAddress: StreetAddress) {
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.streetAddress = streetAddress
    }
    
    init?(json: [String: AnyObject]) {
        guard let first = json["user"]?["first_name"] as? String,
              let last = json["user"]?["first_name"] as? String,
              let phone = json["user"]?["phone"] as? Int,
              let street = json["user"]?["string"] as? String,
              let city = json["user"]?["city"] as? String,
              let state = json["user"]?["state"] as? String,
              let zip = json["user"]?["zip"] as? Int else { return nil }

        self.firstName = first
        self.lastName = last
        self.phoneNumber = phone
        self.district = json["user"]?["district"] as? Int
        self.id = json["user"]?["id"] as? Int
        var streetAddress = StreetAddress()
        streetAddress.city = city
        streetAddress.street = street
        streetAddress.zipCode = zip
        streetAddress.state = state
        self.streetAddress = streetAddress
    }
    
    func toJson(with password: String) -> [String: AnyObject]? {
        guard let street = self.streetAddress.street,
            let city = self.streetAddress.city,
            let state = self.streetAddress.state,
            let zip = self.streetAddress.zipCode else { return nil }
        
        let dict:[String:[String:AnyObject]] = ["user":[
            "first_name": self.firstName,
            "last_name": self.lastName,
            "phone": self.phoneNumber,
            "password": password,
            "address": street,
            "city": city,
            "state": state,
            "zip": zip
            ]
        ]
        return dict
    }
}

struct StreetAddress {
    
    var street: String?
    var city: String?
    var state: String?
    var zipCode: Int?
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