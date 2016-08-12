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
    
    init(repDictionary: [String: AnyObject]) {
       
        self.state = repDictionary["state"] as? String
        self.website = repDictionary["website"] as? String
        self.roleType = repDictionary["role_type_label"] as? String
        if let roleType = roleType {
           self.type = roleType == "Representative" ? .representative : .sentator
        }
        self.leadershipTitle = repDictionary["leadership_title"] as? String
        self.description = repDictionary["description"] as? String
        self.district = repDictionary["district"] as? Int
        self.phoneNumber = repDictionary["phone"] as? String
        self.title = repDictionary["title"] as? String
        self.website = repDictionary["website"] as? String
        self.party = repDictionary["party"] as? String
        self.id = repDictionary["person"]?["id"] as? Int
        self.firstName = repDictionary["person"]?["firstname"] as? String
        self.lastName = repDictionary["person"]?["lastname"] as? String
        self.twitterHandle = repDictionary["person"]?["twitterid"] as? String
        self.imageURL = repDictionary["image"] as? String
    }
}
