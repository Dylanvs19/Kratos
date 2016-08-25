//
//  Legislation.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/30/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import Foundation

struct Vote {
    
    var vote: Vote?
    var id: Int?
    var billResolutionType: String?
    var result: String?
    var date: NSDate?
    var votesFor: Int?
    var votesAgainst: Int?
    var votesAbstain: Int?
    var questionCode: String?
    var questionTitle: String?
    var chamber: String?
    var relatedBill: Int?
    var category: Category = .unknown
    
    var title: String?
    var sourceLink: String?
    
    enum Category: String {
        case amendment = "Amendment"
        case conviction = "Conviction"
        case veto_override = "Veto Override"
        case unknown = "Unknown"
        case impeachment = "Impeachment"
        case passage_suspension = "Passage Suspension"
        case passage_part = "Passage Part"
        case other = "Other"
        case ratification = "Ratification"
        case cloture = "Cloture"
        case passage = "Passage"
        case nomination = "Nomination"
        case procedural = "Procedural"
    }
    
    enum Vote: String {
        case yea = "Yea"
        case nay = "Nay"
        case abstain = "Abstain"
    }
    
    init(json: [String: AnyObject]) {
        if let holdVote = json["value"] as? String {
            switch holdVote {
            case "Yea", "Yes", "Aye":
                self.vote = .yea
            case "Nay", "No":
                self.vote = .nay
            case "Not Voting", "Abstain":
                self.vote = .abstain
            default:
                break
            }
        }
        
        self.id = json["id"] as? Int
        self.relatedBill = json["related_bill"] as? Int
        self.result = json["result"] as? String
        let holdDate = json["created"] as? String
        if let holdDate = holdDate {
            self.date = NSDateFormatter.longDateFormatter.dateFromString(holdDate)
        }
        self.questionTitle = json["question_title"] as? String
        self.questionCode = json["question_code"] as? String
        self.votesFor = json["total_plus"] as? Int
        self.votesAbstain = json["total_other"] as? Int
        self.votesAgainst = json["total_minus"] as? Int
        self.sourceLink = json["link"] as? String
        if let holdCategory = json["category"] as? String {
            switch holdCategory {
            case "amendment":
                self.category = .amendment
            case "conviction":
                self.category = .conviction
            case "veto_override":
                self.category = .veto_override
            case "unknown":
                self.category = .unknown
            case "impeachment":
                self.category = .impeachment
            case "passage_suspension":
                self.category = .passage_suspension
            case "passage_part":
                self.category = .passage_part
            case "other":
                self.category = .other
            case "ratification":
                self.category = .ratification
            case "cloture":
                self.category = .cloture
            case "passage":
                self.category = .passage
            case "nomination":
                self.category = .nomination
            case "procedural":
                self.category = .procedural
            default:
                self.category = .unknown
            }
        }
    }
}