//
//  Term.swift
//  Kratos
//
//  Created by Dylan Straughan on 12/20/16.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//

import Foundation

struct Term: Hashable {
    var hashValue: Int {
        return id
    }
    
    var id: Int
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
    var classNumber: Int?
    
    init?(json: [String: AnyObject]) {
        if let id = json["id"] as? Int {
            self.id = id
        } else {
            return nil
        }
        self.state = json["state"] as? String
        self.district = json["district"] as? Int
        self.classNumber = json["class"] as? Int
        self.officeAddress = json["address"] as? String
        self.isCurrent = json["is_current"] as? Bool
        if let phone = json["phone"] as? String {
            self.phone = phone.trimmingCharacters(in: CharacterSet.decimalDigits.inverted)
        }
        self.website = json["url"] as? String
        self.rank = json["state_rank"] as? String
        self.contactForm = json["contact_form"] as? String

        if let role = json["type"] as? String {
            self.representativeType = Chamber.chamber(value: role)?.representativeType
        }
        if let start = json["start"] as? String {
            self.startDate = start.date
        }
        if let end = json["end"] as? String {
            self.endDate = end.date
        }
        if let party = json["party"] as? String {
            self.party = Party.value(for: party)
        }
    }
    
    ///  returns a formatted date range "M/d/yy - M/d/yy" from the terms start and end dates
    var dateRange: String? {
        guard let startDate = startDate else { return nil }
        var date = DateFormatter.short.string(from: startDate)
        date += " - "
        if let endDate = endDate {
            date += DateFormatter.short.string(from: endDate)
        }
        return date
    }
    
    var formattedDistrict: String? {
        guard let district = district else { return nil }
        return district != 0 ? district.ordinal + " District" : "At Large"
    }
}

func ==(lhs: Term, rhs: Term) -> Bool {
    return lhs.id == rhs.id
}

