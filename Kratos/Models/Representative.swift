//
//  Representative.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/30/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import Foundation

enum Party: String {
    case republican = "Republican"
    case democrat = "Democrat"
    case independent = "Independent"
}
enum RepresentativeType {
    case representative
    case sentator
}

struct Representative {
    
    // From Role API
    var state: String?
    var roleType: String?
    var leadershipTitle: String?
    var description: String?
    var district: Int?
    var phoneNumber: String?
    var title: String?
    var website: String?
    var party: Party?
    var imageURL: String?
    
    // From Person API
    var id: Int?
    var firstName: String?
    var lastName: String?
    var twitterHandle: String?
    var representativeType : RepresentativeType?
    var votes: [Vote]?
    
    init(from json: [String: AnyObject]) {
       
        self.state = json["state"] as? String
        self.website = json["website"] as? String
        if let roleType = json["role_type_label"] as? String {
           self.representativeType = roleType == "Representative" ? .representative : .sentator
        }
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
        self.leadershipTitle = json["leadership_title"] as? String
        self.description = json["description"] as? String
        self.district = json["district"] as? Int
        self.phoneNumber = json["phone"] as? String
        self.title = json["title"] as? String
        self.website = json["website"] as? String
        self.id = json["person"]?["id"] as? Int
        self.firstName = json["person"]?["firstname"] as? String
        self.lastName = json["person"]?["lastname"] as? String
        self.twitterHandle = json["person"]?["twitterid"] as? String
        self.imageURL = json["image"] as? String
    }
    
    func toLightRepresentative() -> LightRepresentative {
        var lightRep = LightRepresentative()
        lightRep.firstName = self.firstName
        lightRep.lastName = self.lastName
        lightRep.district = self.district
        lightRep.imageURL = self.imageURL
        lightRep.party = self.party
        lightRep.representativeType = self.representativeType
        return lightRep
    }
}

struct LightRepresentative {
    
    var firstName: String?
    var lastName: String?
    var id: Int?
    var name: String?
    var imageURL: String?
    var district: Int?
    var state: String?
    var party: Party?
    var representativeType: RepresentativeType?

    init(from json: [String: AnyObject]) {
        self.firstName = json["firstname"] as? String
        self.lastName = json["lastname"] as? String
        self.id = json["id"] as? Int
        self.name = json["name"] as? String
        self.imageURL = json["image"] as? String
    }
    
    init() {}
}
