//
//  User.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/31/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

struct User {
    
    var phoneNumber: Int?
    var streetAddress: StreetAddress?
    var district: Int?
    var id: Int?
    var password: String?
    var token: String?
    var dob: Date?
    var party: Party?
    var userVotes: [UserVote]?
    
    init() { }
    
    init(firstName: String, lastName: String, phoneNumber: Int, streetAddress: StreetAddress) {

        self.phoneNumber = phoneNumber
        self.streetAddress = streetAddress
    }
    
    init?(json: [String: AnyObject], pureUser: Bool = false) {
        var jsonDict = json
        if pureUser {
            jsonDict = ["user": jsonDict as AnyObject]
        } else {
            self.token = jsonDict["token"] as? String
        }
        
        guard let phone = jsonDict["user"]?["phone"] as? Int,
              let street = jsonDict["user"]?["address"] as? String,
              let city = jsonDict["user"]?["city"] as? String,
              let state = jsonDict["user"]?["state"] as? String,
              let district = jsonDict["user"]?["district"] as? Int,
              let id = jsonDict["user"]?["id"] as? Int,
              let zip = jsonDict["user"]?["zip"] as? Int else { return nil }
        
        if let repParty = json["party"] as? String {
            switch repParty {
            case "Republican":
                party = .republican
            case "Democrat":
                party = .democrat
            case "Independent":
                party = .independent
            default:
                break
            }
        }
        
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
            let phoneNumber = self.phoneNumber,
            let party = party?.rawValue,
            let dob = dob else { return nil }
        
        let dict:[String:[String:AnyObject]] = ["user":[
                                                "phone": phoneNumber as AnyObject,
                                                "password": password as AnyObject,
                                                "apn_token": UIDevice.current.identifierForVendor?.uuidString as AnyObject,
                                                "party": party as AnyObject,
                                                "birthday": DateFormatter.billDateFormatter.string(from: dob) as AnyObject,
                                                "address": street as AnyObject,
                                                "city": city as AnyObject,
                                                "state": state as AnyObject,
                                                "zip": zip as AnyObject
                                                ]
                                                ]
        return dict as [String : AnyObject]?
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
            let city = self.city,
            let state = self.state,
            let zipCode = self.zipCode {
            
            returnDictionary = [ "address" : "\(street) \(city) \(state) \(zipCode)" ]
        }
        return returnDictionary
    }
}
