//
//  Tally.swift
//  Kratos
//
//  Created by Dylan Straughan on 12/20/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import Foundation

enum TallyType: String, RawRepresentable {
    case amendment = "Amendment"
    case conviction = "Conviction"
    case vetoOverride = "Veto Override"
    case unknown = "Unknown"
    case impeachment = "Impeachment"
    case passageSuspension = "Passage Suspension"
    case passagePart = "Passage Part"
    case other = "Other"
    case ratification = "Ratification"
    case cloture = "Cloture"
    case passage = "Passage"
    case nomination = "Nomination"
    case procedural = "Procedural"
    
    static func tallyType(for string: String) -> TallyType {
        switch string {
        case "amendment":
            return .amendment
        case "conviction":
            return .conviction
        case "veto_override":
            return .vetoOverride
        case "unknown":
            return .unknown
        case "impeachment":
            return .impeachment
        case "passage_suspension":
            return .passageSuspension
        case "passage_part":
            return .passagePart
        case "other":
            return .other
        case "ratification":
            return .ratification
        case "cloture":
            return .cloture
        case "passage":
            return .passage
        case "nomination":
            return .nomination
        case "procedural":
            return .procedural
        default:
            return .unknown
        }
    }
}

enum TallyResultType: String, RawRepresentable {
    // Agreed To
    case billPassed = "Bill Passed"
    case clotureMotionAgreedTo = "Cloture Motion Agreed to"
    case motionToTableAgreedTo = "Motion to Table Agreed to"
    case motionToProceedAgreedTo = "Motion to Proceed Agreed to"
    case concurrentResolutionAgreedTo = "Concurrent Resolution Agreed to"
    case amendmentAgreedTo = "Amendment Agreed to"
    case clotureOnTheMotionToProceedAgreedTo = "Cloture on the Motion to Proceed Agreed to"
    case motionAgreedTo = "Motion Agreed to"
    case agreedTo = "Agreed to"
    case conferenceReportAgreedTo = "Conference Report Agreed to"
    case passed = "Passed"
    case resolutionAgreedTo = "Resolution Agreed to"
    case jointResolutionPassed = "Joint Resolution Passed"
    case vetoOverridden = "Veto Overridden"
    
    // Rejected
    case clotureOnTheMotionToProceedRejected = "Cloture on the Motion to Proceed Rejected"
    case failed = "Failed"
    case motionRejected = "Motion Rejected"
    case amendmentRejected = "Amendment Rejected"
    case motionToTableFailed = "Motion to Table Failed"
    case clotureMotionRejected = "Cloture Motion Rejected"

    // Other
    case unknown = "Unknown"
    
}

struct Tally: Hashable {
    var hashValue: Int {
        return id
    }
    
    var id: Int
    var yea: Int?
    var nay: Int?
    var abstain: Int?
    var result: TallyResultType?
    var resultText: String?
    var question: String?
    var treaty: String?
    var subject: String?
    var requires: String?
    var lastRecordUpdate: String?
    var amendment: Amendment?
    var type: String?
    var billID: Int?
    var billShortTitle: String?
    var billOfficialTitle: String?
    
    var date: Date?
    var chamber: Chamber?
    var category: TallyType?
    var votes: [Vote]?
    
    init?(json: [String: AnyObject]) {
        
        if let id = json["id"] as? Int {
            self.id = id
        } else {
            return nil
        }
        
        self.yea = buildYeaVote(from: json) ?? 0
        self.abstain = buildAbstainVote(from: json) ?? 0
        self.nay = buildNayVote(from: json) ?? 0
        self.resultText = json["result_text"] as? String
        if let result = json["result"] as? String {
            self.result = TallyResultType(rawValue: result)
        }
        self.treaty = json["treaty"] as? String
        self.subject = json["subject"] as? String
        self.requires = json["requires"] as? String
        self.lastRecordUpdate = json["record_updated_at"] as? String
        if let amendment = json["amendment"] as? [String: AnyObject] {
            self.amendment = Amendment(from: amendment)
        }
        self.type = json["type"] as? String
        self.billID = json["bill_id"] as? Int
        self.billShortTitle = json["bill_short_title"] as? String
        self.billOfficialTitle = json["bill_official_title"] as? String
        
        if let holdDate = json["date"] as? String {
            self.date = holdDate.stringToDate()
        }
        self.question = json["question"] as? String
        if let category = json["category"] as? String {
            self.category = TallyType.tallyType(for: category)
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

func ==(lhs: Tally, rhs: Tally) -> Bool {
    return lhs.id == rhs.id
}

struct LightTally: Hashable {
    var hashValue: Int {
        return id
    }
    var id: Int
    var yea: Int?
    var nay: Int?
    var abstain: Int?
    var result: TallyResultType?
    var resultText: String?
    var question: String?
    var treaty: String?
    var subject: String?
    var requires: String?
    var lastRecordUpdate: String?
    var amendment: Amendment?
    var type: String?
    
    var date: Date?
    var chamber: Chamber?
    var category: TallyType?
    var voteValue: VoteValue?
    
    var billShortTitle: String?
    var billOfficialTitle: String?
    var billID: Int?
    
    init?(json: [String: AnyObject]) {
        
        if let id = json["tally"]?["id"] as? Int {
            self.id = id
        } else {
            return nil
        }

        self.yea = json["tally"]?["total_plus"] as? Int
        self.abstain = json["tally"]?["total_other"] as? Int
        self.nay = json["tally"]?["total_minus"] as? Int
        if let result = json["tally"]?["result"] as? String {
            self.result = TallyResultType(rawValue: result)
        }
        self.resultText = json["tally"]?["result_text"] as? String
        self.treaty = json["tally"]?["treaty"] as? String
        self.subject = json["tally"]?["subject"] as? String
        self.requires = json["tally"]?["requires"] as? String
        self.lastRecordUpdate = json["tally"]?["record_updated_at"] as? String
        if let amendment = json["tally"]?["amendment"] as? [String: AnyObject] {
            self.amendment = Amendment(from: amendment)
        }
        self.type = json["tally"]?["type"] as? String
        
        self.billID = json["tally"]?["bill_id"] as? Int
        self.billShortTitle = json["tally"]?["bill_short_title"] as? String
        self.billOfficialTitle = json["tally"]?["bill_official_title"] as? String
        
        if let holdDate = json["tally"]?["date"] as? String {
            self.date = holdDate.stringToDate()
        }
        self.question = json["tally"]?["question"] as? String
        if let category = json["tally"]?["category"] as? String {
            self.category = TallyType.tallyType(for: category)
        }
        if let holdChamber = json["tally"]?["chamber"] as? String {
            self.chamber = Chamber(rawValue: holdChamber)
        }
        if let vote = json["value"] as? String {
            self.voteValue = VoteValue.vote(value: vote)
        }
    }
}

func ==(lhs: LightTally, rhs: LightTally) -> Bool {
    return lhs.id == rhs.id
}

