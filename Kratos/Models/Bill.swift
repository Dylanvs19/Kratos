//
//  Bill.swift
//  Kratos
//
//  Created by Dylan Straughan on 8/23/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import Foundation

struct Bill {
    var title: String?
    var officialTitle: String?
    var id: Int?
    var link: String?
    var billNumber: String?
    var committees: [Committee]?
    var coSponsors: [LightRepresentative]
    var lightSponsor: LightRepresentative?
    var detailedSponsor: DetailedRepresentative?
    var isCurrent: Bool?
    var currentStatus: String?
    var currentStatusDate: Date?
    var isAlive: Bool?
    var terms: [String]?
    var introductionDate: NSDate?
    var relatedBills: [[String: AnyObject]]?
    var majorActions: [[AnyObject]]?
    
    init?(json: [String: AnyObject]) {
        var committees = [Committee]()
        let committeeArray = json["committees"] as? [[String: AnyObject]]
        committeeArray?.forEach({ (dict) in
            committees.append(Committee(from: dict))
        })
        self.committees = committees
        
        var coSponsors = [LightRepresentative]()
        let coSponsorsArray = json["cosponsors"] as? [[String: AnyObject]]
        coSponsorsArray?.forEach({ (dict) in
            coSponsors.append(LightRepresentative(from: dict))
        })
        self.coSponsors = coSponsors
        
        var terms = [String]()
        let termsArray = json["terms"] as? [[String: AnyObject]]
        termsArray?.forEach({ (dict) in
            if let term = dict["name"] as? String {
                terms.append(term)
            }
        })
        self.terms = terms
        
        let titles = json["titles"] as? [[String]]
        titles?.forEach({ (title) in
            if title.contains("official") {
                self.officialTitle = title[2]
            }
        })
        
        if let sponsor = json["sponsor"] as? [String: AnyObject] {
            self.lightSponsor = LightRepresentative(from: sponsor)
        }
        
        self.billNumber = json["display_number"] as? String
        self.isCurrent = json["is_current"] as? Bool
        self.link = json["link"] as? String
        self.title = json["title_without_number"] as? String
        self.id = json["id"] as? Int
        self.isAlive = json["is_alive"] as? Bool
        self.currentStatus = json["current_status_label"] as? String
        self.relatedBills = json["related_bills"] as? [[String: AnyObject]]
        self.majorActions = json["major_actions"] as? [[AnyObject]]
        
        let statusDate = json["current_status_date"] as? String
        if let statusDate = statusDate {
            self.currentStatusDate = DateFormatter.billDateFormatter.date(from: statusDate) as Date?
        }
        
        let introduction = json["introduced_date"] as? String
        if let introduction = introduction {
            self.introductionDate = DateFormatter.billDateFormatter.date(from: introduction) as NSDate?
        }
    }
}

struct Committee {
    var name: String?
    var id: Int?
    var url: String?
    var abbrev: String?
    var commmitteeType: String?
    
    init(from json: [String: AnyObject]) {
        self.name = json["name"] as? String
        self.id = json["id"] as? Int
        self.url = json["url"] as? String
        self.abbrev = json["abbrev"] as? String
        self.commmitteeType = json["committee_type_label"] as? String
    }
}
