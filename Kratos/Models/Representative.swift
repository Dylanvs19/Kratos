//
//  Representative.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/30/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import Foundation

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
    var party: String?
    var imageURL: String?
    
    // From Person API
    var id: Int?
    var firstName: String?
    var lastName: String?
    var twitterHandle: String?
    var type : Type?

    enum Type {
        case representative
        case sentator
    }
    var votes: [Vote]?
    
    init(json: [String: AnyObject]) {
       
        self.state = json["state"] as? String
        self.website = json["website"] as? String
        self.roleType = json["role_type_label"] as? String
        if let roleType = roleType {
           self.type = roleType == "Representative" ? .representative : .sentator
        }
        self.leadershipTitle = json["leadership_title"] as? String
        self.description = json["description"] as? String
        self.district = json["district"] as? Int
        self.phoneNumber = json["phone"] as? String
        self.title = json["title"] as? String
        self.website = json["website"] as? String
        self.party = json["party"] as? String
        self.id = json["person"]?["id"] as? Int
        self.firstName = json["person"]?["firstname"] as? String
        self.lastName = json["person"]?["lastname"] as? String
        self.twitterHandle = json["person"]?["twitterid"] as? String
        self.imageURL = json["image"] as? String
    }
}
