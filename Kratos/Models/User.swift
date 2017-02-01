//
//  User.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/31/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

struct User {
    
    var email: String?
    var firstName: String?
    var lastName: String?
    var phoneNumber: Int?
    var address: Address?
    var district: Int?
    var id: Int?
    var password: String?
    var token: String?
    var dob: Date?
    var party: Party?
    var apnToken: String?
    
    init() { }
    
    init?(json: [String: AnyObject], pureUser: Bool = false) {
        var jsonDict = json
        if pureUser {
            jsonDict = ["user": jsonDict as AnyObject]
        } else {
            self.token = jsonDict["token"] as? String
        }
        
        guard let phone = jsonDict["user"]?["phone"] as? Int,
              let street = jsonDict["user"]?["address"] as? String,
              let email = jsonDict["user"]?["email"] as? String,
              let firstName = jsonDict["user"]?["first_name"] as? String,
              let lastName = jsonDict["user"]?["last_name"] as? String,
              let city = jsonDict["user"]?["city"] as? String,
              let state = jsonDict["user"]?["state"] as? String,
              let district = jsonDict["user"]?["district"] as? Int,
              let id = jsonDict["user"]?["id"] as? Int,
              let zip = jsonDict["user"]?["zip"] as? Int else { return nil }
        
        if let party = json["party"] as? String {
            self.party = Party.party(value: party)
        }
        if let dob = json["birthday"] as? String {
            self.dob = DateFormatter.billDateFormatter.date(from: dob)
        }
        
        self.phoneNumber = phone
        self.district = district
        self.id = id
        self.email = email
        self.apnToken = jsonDict["user"]?["apn_token"] as? String
        self.firstName = firstName
        self.lastName = lastName
        var address = Address()
        address.city = city
        address.street = street
        address.zipCode = zip
        address.state = state.uppercased()
        self.address = address
        
    }
    
    init?(forUpdate json: [String: AnyObject]) {
        guard let phone = json["phone"] as? Int,
            let street = json["address"] as? String,
            let email = json["email"] as? String,
            let firstName = json["first_name"] as? String,
            let lastName = json["last_name"] as? String,
            let city = json["city"] as? String,
            let state = json["state"] as? String,
            let district = json["district"] as? Int,
            let id = json["id"] as? Int,
            let zip = json["zip"] as? Int else { return nil }
        
        if let party = json["party"] as? String {
            self.party = Party.party(value: party)
        }
        if let dob = json["birthday"] as? String {
            self.dob = DateFormatter.billDateFormatter.date(from: dob)
        }
        
        self.phoneNumber = phone
        self.district = district
        self.id = id
        self.email = email
        self.apnToken = json["apn_token"] as? String
        self.firstName = firstName
        self.lastName = lastName
        var address = Address()
        address.city = city
        address.street = street
        address.zipCode = zip
        address.state = state.uppercased()
        self.address = address
    }
    
    func toJson(with password: String? = nil) -> [String: AnyObject]? {
        guard let street = self.address?.street,
            let city = self.address?.city,
            let state = self.address?.state?.uppercased(),
            let zip = self.address?.zipCode,
            let phoneNumber = self.phoneNumber,
            let party = party?.rawValue,
            let dob = dob,
            let email = email,
            let first = firstName,
            let last = lastName else { return nil }
        
        let dict:[String:[String:AnyObject]] = ["user":[
                                                "phone": phoneNumber as AnyObject,
                                                "email": email.lowercased() as AnyObject,
                                                "first_name": first as AnyObject,
                                                "last_name": last as AnyObject,
                                                "password": password as AnyObject,
                                                "apn_token": apnToken as AnyObject,
                                                "party": party as AnyObject,
                                                "birthday": DateFormatter.utcDateFormatter.string(from: dob) as AnyObject,
                                                "address": street as AnyObject,
                                                "city": city as AnyObject,
                                                "state": state as AnyObject,
                                                "zip": zip as AnyObject
                                                ]
                                                ]
        return dict as [String : AnyObject]?
    }
    
    func toJsonForUpdate() -> [String: AnyObject]? {
        guard let street = self.address?.street,
              let city = self.address?.city,
              let state = self.address?.state?.uppercased(),
              let zip = self.address?.zipCode,
              let phoneNumber = phoneNumber,
              let party = party?.rawValue,
              let dob = dob,
              let first = firstName,
              let last = lastName else { return nil }
        
        let userDict = [
            "phone": phoneNumber,
            "first_name": first,
            "last_name": last,
            "apn_token": apnToken ?? "",
            "party": party,
            "birthday": DateFormatter.utcDateFormatter.string(from: dob),
            "address": street,
            "city": city,
            "state": state,
            "zip": zip
        ] as [String : Any]
        
        return ["user": userDict as AnyObject]
    }
}

struct Address {
    
    var street: String?
    var city: String?
    var state: String?
    var zipCode: Int?
    var dictionaryFormat: [String: String]? {
        var returnDictionary: [String: String]?
        if let
            street = self.street,
            let city = self.city,
            let state = self.state,
            let zipCode = self.zipCode {
            
            returnDictionary = [ "address" : "\(street) \(city) \(state) \(zipCode)" ]
        }
        return returnDictionary
    }
}
