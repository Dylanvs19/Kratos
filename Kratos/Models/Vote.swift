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
    var person: LightRepresentative?
        
    init(json: [String: AnyObject]) {
        if let holdVote = json["value"] as? String {
            self.voteValue = VoteValue.vote(value: holdVote)
        }
        self.person = LightRepresentative() 
        self.person?.id = json["id"] as? Int
        self.person?.imageURL = json["person_image"] as? String
        self.person?.firstName = json["person_firstname"] as? String
        self.person?.lastName = json["person_lastname"] as? String
        if let party = json["person_current_party"] as? String {
            self.person?.party = Party.party(value: party)
        }
        if let state = json["person_current_state"] as? String {
            if state.characters.count > 2 {
                self.person?.representativeType = .representative
                let finalState = state.trimmingCharacters(in: CharacterSet.decimalDigits)
                self.person?.state = finalState
                let district = state.trimmingCharacters(in: CharacterSet.decimalDigits.inverted)
                self.person?.district = Int(district)
            } else {
                self.person?.representativeType = .senator
                self.person?.state = state
            }
        }
    }
    init() {}
}


