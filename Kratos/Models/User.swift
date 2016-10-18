//
//  User.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/31/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import Foundation

struct User {
    
    var firstName: String?
    var lastName: String?
    var phoneNumber: Int?
    var streetAddress: StreetAddress?
    var district: Int?
    var id: Int?
    var password: String?
    var token: String?
    
    init() {
        
    }
    
    init(firstName: String, lastName: String, phoneNumber: Int, streetAddress: StreetAddress) {
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.streetAddress = streetAddress
    }
    
    init?(json: [String: AnyObject], pureUser: Bool = false) {
        var jsonDict = json
        if pureUser {
            jsonDict = ["user": jsonDict]
        } else {
            self.token = jsonDict["token"] as? String
        }
        
        guard let first = jsonDict["user"]?["first_name"] as? String,
            let last = jsonDict["user"]?["last_name"] as? String,
            let phone = jsonDict["user"]?["phone"] as? Int,
            let street = jsonDict["user"]?["address"] as? String,
            let city = jsonDict["user"]?["city"] as? String,
            let state = jsonDict["user"]?["state"] as? String,
            let district = jsonDict["user"]?["district"] as? Int,
            let id = jsonDict["user"]?["id"] as? Int,
            let zip = jsonDict["user"]?["zip"] as? Int else { return nil }
        
        self.firstName = first
        self.lastName = last
        self.phoneNumber = phone
        self.district = district
        self.id = id
        var streetAddress = StreetAddress()
        streetAddress.city = city
        streetAddress.street = street
        streetAddress.zipCode = zip
        streetAddress.state = state
        self.streetAddress = streetAddress
        
    }
    
    func toJson(with password: String) -> [String: AnyObject]? {
        guard let street = self.streetAddress?.street,
            let city = self.streetAddress?.city,
            let state = self.streetAddress?.state,
            let zip = self.streetAddress?.zipCode,
            let first = self.firstName,
            let last = self.lastName,
            let phoneNumber = self.phoneNumber else { return nil }
        
        let dict:[String:[String:AnyObject]] = ["user":[
                                                "first_name": first,
                                                "last_name": last,
                                                "phone": phoneNumber,
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
    var dictionaryFormat: [String: String]? {
        var returnDictionary: [String: String]?
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
