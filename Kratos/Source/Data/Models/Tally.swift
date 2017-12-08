//
//  Tally.swift
//  Kratos
//
//  Created by Dylan Straughan on 12/20/16.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//

import UIKit

enum TallyType {
    case amendment
    case conviction
    case vetoOverride
    case unknown
    case impeachment
    case passageSuspension
    case passagePart
    case ratification
    case cloture
    case passage
    case nomination
    case procedural
    case other(name: String?)
    
    var title: String {
        switch self {
        case .amendment: return "Amendment"
        case .conviction: return "Conviction"
        case .vetoOverride: return "Veto Override"
        case .unknown: return "Unknown"
        case .impeachment: return "Impeachment"
        case .passageSuspension: return "Passage Suspension"
        case .passagePart: return "Passage Part"
        case .ratification: return "Ratification"
        case .cloture: return "Cloture"
        case .passage: return "Passage"
        case .nomination: return "Nomination"
        case .procedural: return "Procedural"
        case .other(let string): return string ?? "Unknown"
        }
    }
    
    static func type(for string: String) -> TallyType {
        switch string {
        case "amendment": return .amendment
        case "conviction": return .conviction
        case "veto_override": return .vetoOverride
        case "unknown": return .unknown
        case "impeachment": return .impeachment
        case "passage_suspension": return .passageSuspension
        case "passage_part": return .passagePart
        case "ratification": return .ratification
        case "cloture": return .cloture
        case "passage": return .passage
        case "nomination": return .nomination
        case "procedural": return .procedural
        default: return .other(name: string)
        }
    }
}

func ==(lhs:TallyType, rhs:TallyType) -> Bool {
    return (lhs.title == rhs.title)
}

enum TallyResult {
    // Agreed To
    case billPassed
    case clotureMotionAgreedTo
    case motionToTableAgreedTo
    case motionToProceedAgreedTo
    case concurrentResolutionAgreedTo
    case amendmentAgreedTo
    case clotureOnTheMotionToProceedAgreedTo
    case motionAgreedTo
    case agreedTo
    case conferenceReportAgreedTo
    case passed
    case resolutionAgreedTo
    case jointResolutionPassed
    case vetoOverridden
    
    // Rejected
    case clotureOnTheMotionToProceedRejected
    case failed
    case motionRejected
    case amendmentRejected
    case motionToTableFailed
    case clotureMotionRejected
    
    // Other
    case unknown
    
    var presentable: String {
        switch self {
        // Agreed To
        case .billPassed: return "Bill Passed"
        case .clotureMotionAgreedTo: return "Cloture Motion Agreed to"
        case .motionToTableAgreedTo: return "Motion to Table Agreed to"
        case .motionToProceedAgreedTo: return "Motion to Proceed Agreed to"
        case .concurrentResolutionAgreedTo: return "Concurrent Resolution Agreed to"
        case .amendmentAgreedTo: return "Amendment Agreed to"
        case .clotureOnTheMotionToProceedAgreedTo: return "Cloture on the Motion to Proceed Agreed to"
        case .motionAgreedTo: return "Motion Agreed to"
        case .agreedTo: return "Agreed to"
        case .conferenceReportAgreedTo: return "Conference Report Agreed to"
        case .passed: return "Passed"
        case .resolutionAgreedTo: return "Resolution Agreed to"
        case .jointResolutionPassed: return "Joint Resolution Passed"
        case .vetoOverridden: return "Veto Overridden"
            
        // Rejected
        case .clotureOnTheMotionToProceedRejected: return "Cloture on the Motion to Proceed Rejected"
        case .failed: return "Failed"
        case .motionRejected: return "Motion Rejected"
        case .amendmentRejected: return "Amendment Rejected"
        case .motionToTableFailed: return "Motion to Table Failed"
        case .clotureMotionRejected: return "Cloture Motion Rejected"
            
        // Other
        default: return "Unknown"
        }
    }
    
    static func value(from string: String) -> TallyResult {
        switch string {
        // Agreed To
        case "Bill Passed" : return .billPassed
        case "Cloture Motion Agreed to": return .clotureMotionAgreedTo
        case "Motion to Table Agreed to": return .motionToTableAgreedTo
        case "Motion to Proceed Agreed to": return .motionToProceedAgreedTo
        case "Concurrent Resolution Agreed to": return .concurrentResolutionAgreedTo
        case "Amendment Agreed to": return .amendmentAgreedTo
        case "Cloture on the Motion to Proceed Agreed to": return .clotureOnTheMotionToProceedAgreedTo
        case "Motion Agreed to": return .motionAgreedTo
        case "Agreed to": return .agreedTo
        case "Conference Report Agreed to":  return .conferenceReportAgreedTo
        case "Passed": return .passed
        case "Resolution Agreed to": return .resolutionAgreedTo
        case "Joint Resolution Passed": return .jointResolutionPassed
        case "Veto Overridden": return .vetoOverridden
            
        // Rejected
        case "Cloture on the Motion to Proceed Rejected": return .clotureOnTheMotionToProceedRejected
        case "Failed": return .failed
        case "Motion Rejected": return .motionRejected 
        case "Amendment Rejected": return .amendmentRejected
        case "Motion to Table Failed": return .motionToTableFailed 
        case "Cloture Motion Rejected":  return .clotureMotionRejected
            
        // Other
        default: return .unknown
        }
    }
    
    var color: UIColor {
        switch self {
        case .billPassed,
             .clotureMotionAgreedTo,
             .motionToTableAgreedTo,
             .motionToProceedAgreedTo,
             .concurrentResolutionAgreedTo,
             .amendmentAgreedTo,
             .clotureOnTheMotionToProceedAgreedTo,
             .motionAgreedTo,
             .agreedTo,
             .conferenceReportAgreedTo,
             .passed,
             .resolutionAgreedTo,
             .jointResolutionPassed,
             .vetoOverridden:
            return UIColor.kratosGreen
        case .clotureOnTheMotionToProceedRejected,
             .failed,
             .motionRejected,
             .amendmentRejected,
             .clotureMotionRejected:
            return UIColor.kratosRed
        default:
            return UIColor.lightGray
        }
    }
    
}

struct Tally: Hashable, JSONDecodable {
    var hashValue: Int {
        return id
    }
    
    var id: Int
    var yea: Int?
    var nay: Int?
    var abstain: Int?
    
    var result: TallyResult?
    var resultText: String?
    var question: String?
    
    var subject: String?
    var requires: String?
    var lastRecordUpdate: String?
    var amendment: Amendment?
    var type: String?
    
    var billID: Int?
    var billShortTitle: String?
    var billOfficialTitle: String?
    var billChamber: Chamber?
    var topSubject: Int?
    var prettyGpoID: String?
    var gpoID: String?
    var congressNumber: Int?
    
    var treaty: String?
    var nominationID: Int?
    
    var date: Date?
    var chamber: Chamber?
    var category: TallyType?
    var votes: [Vote]?
    
    var billTitle: String? {
        return billShortTitle != nil ? billShortTitle : billOfficialTitle
    }
    
    init?(json: [String: Any]) {
        
        guard let id = json["id"] as? Int,
              let dateString = json["date"] as? String,
              let date = dateString.date else { return nil }
        
        self.id = id
        self.date = date
        
        self.yea = buildYeaVote(from: json as [String : AnyObject]) ?? 0
        self.abstain = buildAbstainVote(from: json as [String : AnyObject]) ?? 0
        self.nay = buildNayVote(from: json as [String : AnyObject]) ?? 0
        self.resultText = json["result_text"] as? String
        if let result = json["result"] as? String {
            self.result = TallyResult.value(from: result)
        }
        self.treaty = json["treaty"] as? String
        self.subject = json["subject"] as? String
        self.requires = json["requires"] as? String
        self.lastRecordUpdate = json["record_updated_at"] as? String
        if let amendment = json["amendment"] as? [String: AnyObject] {
            self.amendment = Amendment(from: amendment)
        }
        self.type = json["type"] as? String
        
        if let bill = json["bill"] as? [String: AnyObject] {
            self.billID = bill["id"] as? Int
            self.billShortTitle = bill["short_title"] as? String
            self.billOfficialTitle = bill["official_title"] as? String
            if let chamber = bill["type"] as? String {
                self.billChamber = Chamber.chamber(value: chamber)
            }
            self.topSubject = bill["top_subject_id"] as? Int
            self.prettyGpoID = bill["pretty_gpo"] as? String
            self.gpoID = bill["gpo_id"] as? String
            self.congressNumber = bill["congress_number"] as? Int
        }
        if let tally = json["tally"] as? [String: Int] {
            self.nominationID = tally["nomination_id"]
        }
        
        self.question = json["question"] as? String
        if let category = json["category"] as? String {
            self.category = TallyType.type(for: category)
        }
        if let holdChamber = json["chamber"] as? String {
            self.chamber = Chamber.chamber(value: holdChamber)
        }
        if let voteArray = json["votes"] as? [[String: AnyObject]] {
            votes = voteArray.map { Vote(json: $0) }
                             .flatMap { $0 }
                             .sorted(by: { $0 .person?.state.rawValue ?? "z" < $1.person?.state.rawValue ?? "z" })
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

struct LightTally: Hashable, JSONDecodable {
    var hashValue: Int {
        return id
    }
    var id: Int
    var yea: Int?
    var nay: Int?
    var abstain: Int?
    var result: TallyResult?
    var resultText: String?
    var question: String?
    var treaty: String?
    var subject: String?
    var requires: String?
    var lastRecordUpdate: String?
    var amendment: Amendment?
    var type: String?
    
    var date: Date
    var chamber: Chamber?
    var category: TallyType?
    var voteValue: VoteValue?
    
    var billId: Int?
    var billShortTitle: String?
    var billOfficialTitle: String?
    var billChamber: Chamber?
    var topSubject: Subject?
    var prettyGpoId: String?
    var gpoId: String?
    var congressNumber: Int?
    
    var nominationID: Int?
    
    var billTitle: String? {
        return billShortTitle != nil ? billShortTitle : billOfficialTitle
    }
    
    init?(json: [String: Any]) {
        guard let tally = json["tally"] as? [String: Any],
              let id = tally["id"] as? Int,
              let holdDate = tally["date"] as? String,
              let date = holdDate.date else { return nil }
        
        self.id = id
        self.date = date

        self.yea = tally["total_plus"] as? Int
        self.abstain = tally["total_other"] as? Int
        self.nay = tally["total_minus"] as? Int
        if let result = tally["result"] as? String {
            self.result = TallyResult.value(from: result)
        }
        self.resultText = tally["result_text"] as? String
        self.treaty = tally["treaty"] as? String
        self.subject = tally["subject"] as? String
        self.requires = tally["requires"] as? String
        self.lastRecordUpdate = tally["record_updated_at"] as? String
        if let amendment = tally["amendment"] as? [String: AnyObject] {
            self.amendment = Amendment(from: amendment)
        }
        self.type = tally["type"] as? String
        
        if let bill = tally["bill"] as? [String: AnyObject] {
            self.billId = bill["id"] as? Int
            self.billShortTitle = bill["short_title"] as? String
            self.billOfficialTitle = bill["official_title"] as? String
            if let chamber = bill["type"] as? String {
                self.billChamber = Chamber.chamber(value: chamber)
            }
            if let subject = bill["top_subject"] as? [String: Any] {
                self.topSubject = Subject(json: subject)
            }
            self.prettyGpoId = bill["pretty_gpo"] as? String
            self.gpoId = bill["gpo_id"] as? String
            self.congressNumber = bill["congress_number"] as? Int
        }
        
        self.nominationID = tally["nomination_id"] as? Int
        
        self.question = tally["question"] as? String
        if let category = tally["category"] as? String {
            self.category = TallyType.type(for: category)
        }
        if let holdChamber = tally["chamber"] as? String {
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

