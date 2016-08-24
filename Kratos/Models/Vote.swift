//
//  Legislation.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/30/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import Foundation

struct Vote {
    
    var vote: String?
    var id: Int?
    var billResolutionType: String?
    var result: String?
    var category: String?
    var date: NSDate?
    var votesFor: Int?
    var votesAgainst: Int?
    var votesAbstain: Int?
    var question: String?
    var chamber: String?
    var relatedBill: String?
    
    var title: String?
    var sourceLink: String?
    
    enum category: String {
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
    
    init(json: [String: AnyObject]) {
        self.vote = json["value"] as? String
        self.id = json["id"] as? Int
        self.category = json["category"] as? String
        self.relatedBill = json["related_bill"] as? String
        self.result = json["result"] as? String
        let holdDate = json["created"] as? String
        if let holdDate = holdDate {
            self.date = NSDateFormatter.longDateFormatter.dateFromString(holdDate)
        }
        self.question = json["question"] as? String
        self.votesFor = json["total_plus"] as? Int
        self.votesAbstain = json["total_other"] as? Int
        self.votesAgainst = json["total_minus"] as? Int
        self.sourceLink = json["link"] as? String
    }
}