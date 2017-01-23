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
    
    var voteValue: VoteValue?
    var person: LightPerson?
    var id: Int?
        
    init(json: [String: AnyObject]) {
        if let holdVote = json["value"] as? String {
            self.voteValue = VoteValue.vote(value: holdVote)
        }
        
        if let person = json["person"] as? [String: AnyObject] {
            self.person = LightPerson(from: person)
        }
        self.id = json["id"] as? Int 
    }
    init() {}
}


