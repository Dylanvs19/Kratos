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
    var billId: Int?
    var billShortTitle: String?
    var billOfficialTitle: String?
    
    var date: Date?
    var chamber: Chamber?
    var category: TallyType?
    var votes: [Vote]?
    
    init(json: [String: AnyObject]) {
        
        self.id = json["id"] as? Int
        self.yea = buildYeaVote(from: json) ?? 0
        self.abstain = buildAbstainVote(from: json) ?? 0
        self.nay = buildNayVote(from: json) ?? 0
        self.result = json["result"] as? String
        self.treaty = json["treaty"] as? String
        self.subject = json["subject"] as? String
        self.requires = json["requires"] as? String
        self.lastRecordUpdate = json["record_updated_at"] as? String
        self.amendment = json["amendment"] as? String
        self.type = json["type"] as? String
        self.billId = json["bill_id"] as? Int
        self.billShortTitle = json["bill_short_title"] as? String
        self.billOfficialTitle = json["bill_official_title"] as? String
        
        if let holdDate = json["date"] as? String {
            self.date = holdDate.stringToDate()
        }
        self.question = json["question"] as? String
        if let holdCategory = json["category"] as? String {
            self.category = TallyType(rawValue: holdCategory) ?? .unknown
        }
        if let holdChamber = json["chamber"] as? String {
            self.chamber = Chamber.chamber(value: holdChamber)
        }
        if let voteArray = json["votes"] as? [[String: AnyObject]] {
            votes = voteArray.map({ (dictionary) -> Vote? in
                return Vote(json: dictionary)
            }).flatMap({$0}).sorted(by: {$0.person?.state ?? "z" < $1.person?.state ?? "z"})
        }
    }
    
    fileprivate func buildYeaVote(from json: [String: AnyObject]) -> Int? {
        var int:Int? = nil
        if let yea = json["Aye"] as?  Int {
            int = yea
        } else if let yea = json["Yea"] as?  Int {
            int = yea
        } else if let yea = json["Yes"] as?  Int {
            int = yea
        }
        return int
    }
    fileprivate func buildNayVote(from json: [String: AnyObject]) -> Int? {
        var int:Int? = nil
        if let no = json["Nay"] as?  Int {
            int = no
        } else if let no = json["No"] as?  Int {
            int = no
        }
        return int
    }
    fileprivate func buildAbstainVote(from json: [String: AnyObject]) -> Int? {
        var int:Int? = nil
        if let abstain = json["Not Voting"] as?  Int {
            int = abstain
        } else if let abstain = json["Abstain"] as?  Int {
            int = abstain
        } else if let abstain = json["Absent"] as?  Int {
            int = abstain
        }
        return int
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
    var voteValue: VoteValue?
    var billShortTitle: String?
    var billOfficialTitle: String?
    
    init(json: [String: AnyObject]) {
        
        self.id = json["tally"]?["id"] as? Int
        self.yea = json["tally"]?["total_plus"] as? Int
        self.abstain = json["tally"]?["total_other"] as? Int
        self.nay = json["tally"]?["total_minus"] as? Int
        self.result = json["tally"]?["result"] as? String
        self.treaty = json["tally"]?["treaty"] as? String
        self.subject = json["tally"]?["subject"] as? String
        self.requires = json["tally"]?["requires"] as? String
        self.billShortTitle = json["tally"]?["bill_short_title"] as? String
        self.billOfficialTitle = json["tally"]?["bill_official_title"] as? String
        self.lastRecordUpdate = json["tally"]?["record_updated_at"] as? String
        if let amendment = json["tally"]?["amendment"] as? String {
            self.amendment = json["tally"]?["amendment"] as? String
        }
        self.type = json["tally"]?["type"] as? String
        
        if let holdDate = json["tally"]?["date"] as? String {
            self.date = holdDate.stringToDate()
        }
        self.question = json["tally"]?["question"] as? String
        if let holdCategory = json["tally"]?["category"] as? String {
            self.category = TallyType(rawValue: holdCategory) ?? .unknown
        }
        if let holdChamber = json["tally"]?["chamber"] as? String {
            self.chamber = Chamber(rawValue: holdChamber)
        }
        if let vote = json["value"] as? String {
            self.voteValue = VoteValue.vote(value: vote)
        }
        
    }
}
