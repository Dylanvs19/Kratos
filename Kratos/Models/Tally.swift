//
//  Tally.swift
//  Kratos
//
//  Created by Dylan Straughan on 12/20/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import Foundation

enum TallyType: String, RawRepresentable {
    case amendment = "amendment"
    case conviction = "conviction"
    case veto_override = "veto_override"
    case unknown = "unknown"
    case impeachment = "impeachment"
    case passage_suspension = "passage_suspension"
    case passage_part = "passage_part"
    case other = "other"
    case ratification = "ratification"
    case cloture = "cloture"
    case passage = "passage"
    case nomination = "nomination"
    case procedural = "procedural"
}

struct Tally {
    
    var id: Int?
    var yea: Int?
    var nay: Int?
    var abstain: Int?
    var result: String?
    var question: String?
    var treaty: String?
    var subject: String?
    var requires: String?
    var lastRecordUpdate: String?
    var amendment: String?
    var type: String?
    var billID: Int?
    
    var date: Date?
    var chamber: Chamber?
    var category: TallyType?
    var votes: [Vote]?
    
    init(json: [String: AnyObject]) {
        
        self.id = json["id"] as? Int
        self.yea = json["total_plus"] as? Int
        self.abstain = json["total_other"] as? Int
        self.nay = json["total_minus"] as? Int
        self.result = json["result"] as? String
        self.treaty = json["treaty"] as? String
        self.subject = json["subject"] as? String
        self.requires = json["requires"] as? String
        self.lastRecordUpdate = json["record_updated_at"] as? String
        self.amendment = json["amendment"] as? String
        self.type = json["type"] as? String
        self.billID = json["bill_id"] as? Int
        
        if let holdDate = json["created"] as? String {
            self.date = DateFormatter.longDateFormatter.date(from: holdDate)
        }
        self.question = json["question"] as? String
        if let holdCategory = json["category"] as? String {
            self.category = TallyType(rawValue: holdCategory) ?? .unknown
        }
        if let holdChamber = json["chamber"] as? String {
            self.chamber = Chamber(rawValue: holdChamber)
        }
        if let voteArray = json["votes"] as? [[String: AnyObject]] {
            votes = voteArray.map({ (dictionary) -> Vote? in
                return Vote(json: dictionary)
            }).flatMap({$0})
        }
        
    }
}

struct LightTally {
    var id: Int?
    var yea: Int?
    var nay: Int?
    var abstain: Int?
    var result: String?
    var question: String?
    var treaty: String?
    var subject: String?
    var requires: String?
    var lastRecordUpdate: String?
    var amendment: String?
    var type: String?
    
    var date: Date?
    var chamber: Chamber?
    var category: TallyType?
    var vote: VoteValue?
    
    init(json: [String: AnyObject]) {
        
        self.id = json["id"] as? Int
        self.yea = json["total_plus"] as? Int
        self.abstain = json["total_other"] as? Int
        self.nay = json["total_minus"] as? Int
        self.result = json["result"] as? String
        self.treaty = json["treaty"] as? String
        self.subject = json["subject"] as? String
        self.requires = json["requires"] as? String
        self.lastRecordUpdate = json["record_updated_at"] as? String
        self.amendment = json["amendment"] as? String
        self.type = json["type"] as? String
        
        if let holdDate = json["created"] as? String {
            self.date = DateFormatter.longDateFormatter.date(from: holdDate)
        }
        self.question = json["question"] as? String
        if let holdCategory = json["category"] as? String {
            self.category = TallyType(rawValue: holdCategory) ?? .unknown
        }
        if let holdChamber = json["chamber"] as? String {
            self.chamber = Chamber(rawValue: holdChamber)
        }
        if let vote = json["value"] as? String {
            self.vote = VoteValue.vote(value: vote)
        }
        
    }
}
