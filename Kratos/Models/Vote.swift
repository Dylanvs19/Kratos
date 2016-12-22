//
//  Legislation.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/30/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import Foundation

enum VoteValue: String {
    case yea = "Yea"
    case nay = "Nay"
    case abstain = "Not Voting"
    
    static func vote(value: String) -> VoteValue? {
        switch value {
        case "Yea", "Yes", "Aye":
            return .yea
        case "Nay", "No":
            return .nay
        case "Not Voting", "Abstain":
            return .abstain
        default:
            return nil
        }
    }
}

struct Vote {
    
    var vote: VoteValue?
    var person: LightRepresentative?
        
    init(json: [String: AnyObject]) {
        if let holdVote = json["value"] as? String {
            self.vote = VoteValue.vote(value: holdVote)
        }
        self.person = LightRepresentative() 
        self.person?.id = json["id"] as? Int
        self.person?.imageURL = json["person_image"] as? String
        self.person?.firstName = json["firstname"] as? String
        self.person?.lastName = json["lastname"] as? String
    }
    
    init() {}
    
    
}


