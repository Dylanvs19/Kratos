//
//  Person.swift
//  Kratos
//
//  Created by Dylan Straughan on 12/20/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import Foundation

struct Person {
    
    var id: Int?
    var firstName: String?
    var lastName: String?
    var currentState: String?
    var currentParty: Party?
    var dob: Date?
    var imageURL: String?
    var twitter: String?
    var youtube: String?
    var gender: String?
    var roles: [Role]?
    var tallies: [LightTally]?
    
    init(json: [String: AnyObject]) {
        self.id = json["id"] as? Int
        self.firstName = json["firstname"] as? String
        self.lastName = json["lastname"] as? String
        self.twitter = json["twitterid"] as? String
        self.youtube = json["youtubeid"] as? String
        self.currentState = json["current_state"] as? String
        if let party = json["current_party"] as? String {
            self.currentParty = Party.party(value: party)
        }
        self.imageURL = json["image_url"] as? String
        self.gender = json["gender"] as? String
        if let dob = json["birthday"] as? String {
            self.dob = DateFormatter.billDateFormatter.date(from: dob)
        }
        if let roleArray = json["roles"] as? [[String: AnyObject]] {
            self.roles = roleArray.map({ (dictionary) -> Role? in
                return Role(json: dictionary)
            }).flatMap({$0})
        }
    }
    
    init() {}
}

