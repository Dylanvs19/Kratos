//
//  Legislation.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/30/16.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//

import Foundation
import UIKit

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
    
    var image: UIImage {
        switch self {
        case .yea:
            return #imageLiteral(resourceName: "Yes")
        case .nay:
            return #imageLiteral(resourceName: "No")
        case .abstain:
            return #imageLiteral(resourceName: "Abstain")
        }
    }
    
    var color: Color {
        switch self {
        case .yea:
            return .kratosGreen
        case .nay:
            return .kratosRed
        case .abstain:
            return .gray
        }
    }
}

struct Vote: JSONDecodable {
    
    var id: Int?
    var voteValue: VoteValue?
    var person: LightPerson?
    
    init?(json: [String: Any]) {
        guard let id = json["id"] as? Int else { return nil }
        self.id = id
        if let holdVote = json["value"] as? String {
            self.voteValue = VoteValue.vote(value: holdVote)
        }
        
        if let person = json["person"] as? [String: AnyObject] {
            self.person = LightPerson(from: person)
        }
    }
    
    init() {}
}


