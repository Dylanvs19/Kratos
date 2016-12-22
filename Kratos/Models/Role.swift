//
//  Role.swift
//  Kratos
//
//  Created by Dylan Straughan on 12/20/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import Foundation

struct Role {
    
    var id: Int?
    var state: String?
    var district: Int?
    var rank: String?
    var classLabel: String?
    var officeAddress: String?
    var current: Bool?
    var phone: String?
    var website: String?
    var startDate: Date?
    var endDate: Date?
    var representativeType: RepresentativeType?
    
    init(json: [String: AnyObject]) {
        self.id = json["id"] as? Int
        self.state = json["state"] as? String
        self.district = json["district"] as? Int
        self.classLabel = json["senator_class_label"] as? String
        self.officeAddress = json["extra"]?["address"] as? String
        self.current = json["current"] as? Bool
        self.phone = json["phone"] as? String
        self.website = json["website"] as? String
        
        if let role = json["role_type_label"] as? String {
            self.representativeType = RepresentativeType(rawValue: role)
        }
        if let start = json["startdate"] as? String {
            self.startDate = DateFormatter.billDateFormatter.date(from: start)
        }
        if let end = json["enddate"] as? String {
            self.endDate = DateFormatter.billDateFormatter.date(from: end)
        }
    }
}
