//
//  User.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/31/16.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//

import UIKit

struct User: JSONDecodable {
    
    var id: Int
    var email: String
    var firstName: String
    var lastName: String
    var address: Address
    var district: District
    var visitingDistrict: District?
    var dob: Date
    var party: Party?
    var password: String?
    var apnToken: String?
    
    var presentingDistrict: District {
        return visitingDistrict ?? district
    }
    
    init(id: Int,
         email: String,
         firstName: String, 
         lastName: String,
         district: District,
         address: Address,
         dob: Date,
         party: Party?,
         password: String? = nil,
         apnToken: String? = nil ) {
        
        self.id = id
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.district = district
        self.address = address
        self.dob = dob
        self.party = party
        self.password = password
        self.apnToken = apnToken
    }
        
    init?(json: [String: Any]) {
        guard let street = json["address"] as? String,
              let email = json["email"] as? String,
              let firstName = json["first_name"] as? String,
              let lastName = json["last_name"] as? String,
              let city = json["city"] as? String,
              let stateString = json["state"] as? String,
              let districtInt = json["district"] as? Int,
              let id = json["id"] as? Int,
              let zip = json["zip"] as? Int,
              let dob = json["birthday"] as? String,
              let state = State(rawValue: stateString) else { return nil }
        
        self.id = id
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.district = District(state: state, district: districtInt)
        self.party = Party.value(for: (json["party"] as? String))
        self.dob = DateFormatter.bill.date(from: dob) ?? Date()
        self.apnToken = json["apn_token"] as? String
        self.address = Address(street: street,
                               city: city,
                               state: stateString.uppercased(),
                               zipCode: zip)
    }
    
    func toJson() -> [String: Any] {
        
        var dict:[String: Any] = [
                                  "email": email.lowercased(),
                                  "first_name": firstName,
                                  "last_name": lastName,
                                  "birthday": DateFormatter.utc.string(from: dob),
                                  "address": self.address.street,
                                  "city": self.address.city,
                                  "state": self.address.state.uppercased(),
                                  "zip": self.address.zipCode
                                  ]
        
        if let party = party {
            dict["party"] = party.long
        }
        if let password = password {
            dict["password"] = password
        }
        if let apnToken = apnToken {
            dict["apn_token"] = apnToken
        }
        
        return ["user":dict]
    }
    
    func update(email: String?,
         firstName: String?,
         lastName: String?,
         district: District?,
         address: Address?,
         dob: Date?,
         party: Party?,
         password: String? = nil,
         apnToken: String? = nil ) -> User {
        
        return User(id: self.id,
                    email: email ?? self.email,
                    firstName: firstName ?? self.firstName,
                    lastName: lastName ?? self.lastName,
                    district: district ?? self.district,
                    address: address ?? self.address,
                    dob: dob ?? self.dob,
                    party: party ?? self.party,
                    password: password ?? self.password,
                    apnToken: apnToken ?? self.apnToken)
    }
}

struct Address {
    
    let street: String
    let city: String
    let state: String
    let zipCode: Int
    
    var dictionaryFormat: [String: String] {
        let returnDictionary: [String: String]
        returnDictionary = [ "address" : "\(street) \(city) \(state) \(zipCode)" ]
        
        return returnDictionary
    }
}
