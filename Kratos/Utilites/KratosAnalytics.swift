//
//  AnalyticActions.swift
//  Kratos
//
//  Created by Dylan Straughan on 1/18/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import UIKit

class KratosAnalytics {
    
    static let shared = KratosAnalytics()
    
    enum ContactAnalyticType: String {
        case phone = "phone"
        case twitter = "twitter"
        case officeAddress = "officeAddress"
        case website = "website"
        
        func fireEvent() {
            APIManager.postKratosAnalyticEvent(event: self, success: { (didSucceed) in
                debugPrint("KratosAnalytics Contact \(self.rawValue): \(didSucceed)")
            }, failure: { (error) in
                debugPrint(error)
            })
        }
    }
    
    var lastBillID: Int?
    var timeBillLastSeenAt: Date?
    var lastTallyID: Int?
    var timeTallyLastSeenAt: Date?
    var lastRepID: Int?
    
    func updateBillAnalyicAction(with billID: Int?) {
        if let billID = billID {
            lastBillID = billID
        }
        timeBillLastSeenAt = Date()
    }
    
    func updateTallyAnalyicAction(with tallyID: Int?) {
        if let tallyID = tallyID {
            lastTallyID = tallyID
        }
        timeTallyLastSeenAt = Date()
    }
    
    func updateRepAnalyicAction(with repID: Int?) {
        if let repID = repID {
            lastRepID = repID
        }
    }
    
    func toDict(with event: ContactAnalyticType) -> [String: [String: AnyObject]]? {
        
        var dict = ["action": event.rawValue as AnyObject,
                    "last_bill_id": lastBillID as AnyObject,
                    "last_tally_id": lastTallyID as AnyObject,
                    "last_rep_id": lastRepID as AnyObject
                    ]
        
        if let timeBillLastSeenAt = timeBillLastSeenAt {
            dict["last_bill_seen_at"] = DateFormatter.utcDateFormatter.string(from: timeBillLastSeenAt) as AnyObject
        }
        if let timeTallyLastSeenAt = timeTallyLastSeenAt {
            dict["last_tally_seen_at"] = DateFormatter.utcDateFormatter.string(from: timeTallyLastSeenAt) as AnyObject
        }
        
        return ["user_action" : dict]
    }
}
