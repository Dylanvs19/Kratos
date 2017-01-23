//
//  Term.swift
//  Kratos
//
//  Created by Dylan Straughan on 12/20/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import Foundation

struct Term {
    
    var id: Int?
    var state: String?
    var district: Int?
    var rank: String?
    var officeAddress: String?
    var phone: String?
    var website: String?
    var startDate: Date?
    var endDate: Date?
    var representativeType: RepresentativeType?
    
    var party: Party?
    var isCurrent: Bool?
    var contactForm: String?
    var `class`: Int?
    
    
    init(json: [String: AnyObject]) {
        self.id = json["id"] as? Int
        self.state = json["state"] as? String
        self.district = json["district"] as? Int
        self.`class` = json["class"] as? Int
        self.officeAddress = json["address"] as? String
        self.isCurrent = json["is_current"] as? Bool
        if let phone = json["phone"] as? String {
            self.phone = phone.trimmingCharacters(in: CharacterSet.decimalDigits.inverted)
        }
        self.website = json["url"] as? String
        self.rank = json["state_rank"] as? String
        self.contactForm = json["contact_form"] as? String

        if let role = json["type"] as? String {
            self.representativeType = Chamber.chamber(value: role)?.toRepresentativeType()
        }
        if let start = json["start"] as? String {
            self.startDate = start.stringToDate()
        }
        if let end = json["end"] as? String {
            self.endDate = end.stringToDate()
        }
        if let party = json["party"] as? String {
            self.party = Party.party(value: party)
        }
    }
}
