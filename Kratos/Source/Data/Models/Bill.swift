//
//  Bill.swift
//  Kratos
//
//  Created by Dylan Straughan on 8/23/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import Foundation
import UIKit

struct Bill: Hashable, Decodable {
    //Id
    var hashValue: Int {
        return id
    }
    var id: Int
    //Titles 
    var title: String? // short title
    var officialTitle: String?
    var popularTitle: String?
    var titles: [Title]?
    //GPO Id's
    var gpoID: String?
    var prettyGpoID: String?
    var congressNumber: Int?
    //Committees
    var committees: [Committee]?
    //Sponsors
    var sponsor: Person?
    var coSponsors: [Person]?
    //Status
    var status: String?
    var statusDate: Date?
    var introductionDate: Date?
    var active: Bool?
    var vetoed: Bool?
    var enacted: Bool?
    var enactedAs: String?
    var awaitingSignature: Bool?
    var actions: [BillAction]?
    //Term
    var topTerm: Int?
    //RelatedBills
    var relatedBills: [RelatedBill]?
    //Summary
    var summary: String?
    var summaryDate: Date?
    //Amendments
    var amendments: [Amendment]?
    //Tallies
    var tallies: [Tally]?
    //BillText
    var billTextURL: String?
    
    //Computed Properties
    var isCurrentlyTracked: Bool {
        //TODO
        //Contains in set on user or bill manager.
        return false
    }
    
    init?(json: [String: Any]) {
        guard let id = json["id"] as? Int else { return nil }
        self.id = id
        
        self.title = json["short_title"] as? String
        self.officialTitle = json["official_title"] as? String
        self.popularTitle = json["popular_title"] as? String
        if  let titles = json["title"] as? [[String: AnyObject]] {
            self.titles = titles.map({ (obj) -> Title in
                return Title(from: obj)
            })
        }
        
        self.gpoID = json["gpo_id"] as? String
        self.prettyGpoID = json["pretty_gpo"] as? String
        self.congressNumber = json["congress_number"] as? Int
        
        if let committeeArray = json["committees"] as? [[String: AnyObject]] {
            self.committees = committeeArray.map({ (obj) -> Committee in
                return Committee(from: obj)
            })
        }
        if let committeeHistoryArray = json["committee_history"] as? [[String: AnyObject]] {
            self.committees = self.committees?.map{
                var returnCommittee = $0
                committeeHistoryArray.forEach({ (committeeHistory) in
                    if let activity = committeeHistory["activity"] as? [String],
                        committeeHistory["committee_id"] as? String == returnCommittee.committeCode {
                        returnCommittee.activity = activity
                    }
                })
                return returnCommittee
            }
        }
        if let sponsor = json["sponsor"] as? [String: AnyObject] {
            self.sponsor = Person(json: sponsor)
        }
        if let coSponsorsArray = json["cosponsors"] as? [[String: AnyObject]] {
             self.coSponsors = coSponsorsArray.flatMap { Person(json: $0) }
        }
        
        self.status = json["status"] as? String
        if let statusString = json["status_at"] as? String {
            self.statusDate = statusString.date
        }
        if let introduction = json["introduced_at"] as? String {
            self.introductionDate = introduction.date
        }
        if let relatedBills = json["related_bills"] as? [[String: AnyObject]] {
            self.relatedBills = relatedBills.flatMap { return RelatedBill(json: $0) }
        }
        if let actions = json["actions"] as? [[String: AnyObject]] {
            self.actions = actions.flatMap { return BillAction(json: $0) }
        }
        
        self.active = json["active"] as? Bool
        self.vetoed = json["vetoed"] as? Bool
        self.enacted = json["enacted"] as? Bool
        self.enactedAs = json["enactedAs"] as? String
        self.awaitingSignature = json["awaiting_signature"] as? Bool
        
        self.topTerm = json["top_term"] as? Int
        self.billTextURL = json["full_text_url"] as? String
        
        self.summary = json["summary_text"] as? String
        if let summaryDate = json["summary_date"] as? String {
            self.summaryDate = summaryDate.date
        }

        if let amendments = json["amendments"] as? [[String: AnyObject]] {
            self.amendments = amendments.map({ (amendment) -> Amendment in
                return Amendment(from: amendment)
            })
        }
        
        if let tallyArray = json["tallies"] as? [[String: AnyObject]] {
            self.tallies = tallyArray.flatMap { Tally(json: $0) }
        }
    }
    
    struct Title {
        var type: String?
        var text: String?
        var isForPortion: Bool?
        var passedAs: String?
        
        init(from json: [String: AnyObject]) {
            self.type = json["type"] as? String
            self.text = json["text"] as? String
            self.isForPortion = json["is_for_portion"] as? Bool
            self.passedAs = json["as"] as? String
        }
    }
}

func ==(lhs: Bill, rhs: Bill) -> Bool {
    return lhs.id == rhs.id
}

struct Amendment {
    
    var number: Int?
    var chamber: Chamber?
    var type: String?
    var id: Int?
    var purpose: String?
    
    init(from json: [String: AnyObject]) {
        self.number = json["number"] as? Int
        self.purpose = json["purpose"] as? String 
        if let chamber = json["chamber"] as? String {
            self.chamber = Chamber.chamber(value: chamber)
        }
        self.type = json["amendment_type"] as? String
        self.id = json["amendment_id"] as? Int
    }
}

enum Chamber: String, RawRepresentable {
    case house = "House of Representatives"
    case senate = "Senate"
    
    static func chamber(value: String) -> Chamber? {
        switch value {
        case "House of Representatives", "House", "house", "house of representatives", "h", "H", "hr", "HR":
            return .house
        case "Senate", "senate", "s", "S":
            return .senate
        default:
            return nil
        }
    }
    
    var representativeType: RepresentativeType {
        switch self {
        case .house:
            return RepresentativeType.representative
        case .senate:
            return RepresentativeType.senator
        }
    }
    
    var image: UIImage {
        switch self {
        case .house:
            return #imageLiteral(resourceName: "HouseOfRepsLogo")
        case .senate:
            return #imageLiteral(resourceName: "SenateLogo")
        }
    }
    
    var pathValue: String {
        switch self {
        case .house:
            return "house"
        case .senate:
            return "senate"
        }
    }
}

struct BillAction: Decodable {
    var type: String?
    var text: String?
    var references: [Reference]?
    var code: String?
    var date: Date?
    var status: String?
    var how: String?
    var chamber: Chamber?
    var committees: [String]?
    var voteType: String?
    var roll: Int?
    var id: Int?
    
    init?(json: [String: Any]) {
        self.type = json["type"] as? String
        self.text = json["text"] as? String
        if let references =  json["references"] as? [[String: AnyObject]] {
            self.references = references.map({ (reference) -> Reference in
                return Reference(from: reference)
            })
        }
        self.committees = json["committees"] as? [String]
        self.voteType = json["vote_type"] as? String
        self.status = json["status"] as? String
        self.roll = json["roll"] as? Int
        self.code = json["action_code"] as? String
        if let date = json["acted_at"] as? String {
            self.date = date.date
        }
    }
    
    func presentableType() -> String? {
        guard let type = self.type else {return nil}
        switch type {
        case "topresident":
            return "To President"
        case "passed:simpleres":
            return "Passed-Simple Resolution"
        case "vote-aux":
            return "Vote Auxiliary"
        default:
            return type.lowercased().capitalized
        }
    }
    
    func presentableStatus() -> String? {
        return self.status?.replacingOccurrences(of: "_", with: " ").replacingOccurrences(of: ":", with: "-").lowercased().capitalized
    }
    
    struct Reference {
        var type: String?
        var reference: String?
        
        init(from json: [String: AnyObject]) {
            self.type = json["type"] as? String
            self.reference = json["reference"] as? String
        }
    }
}

struct Committee {
    var name: String?
    var id: Int?
    var committeCode: String?
    var url: String?
    var abbrev: String?
    var jusrisdiction: String?
    var commmitteeType: Chamber?
    var activity: [String]?
    var phone: String?
    var address: String?
    
    init(from json: [String: AnyObject]) {
        self.name = json["name"] as? String
        self.id = json["id"] as? Int
        self.url = json["url"] as? String
        if let houseID = json["house_committee_id"] as? String {
            self.committeCode = houseID
        } else if let senateID = json["senate_committee_id"] as? String {
            self.committeCode = senateID
        }
        self.abbrev = json["abbrev"] as? String
        self.jusrisdiction = json["jurisdiction"] as? String
        if let chamber = json["type"] as? String {
            self.commmitteeType = Chamber.chamber(value: chamber)
        }
        self.phone = json["phone"] as? String
        self.address = json["address"] as? String

    }
}

struct RelatedBill: Decodable {
    var relatedBillID: Int?
    var reason: String?
    
    init?(json: [String: Any]) {
        self.relatedBillID = json["related_bill_id"] as? Int
        self.reason = json["reason"] as? String
    }
}

