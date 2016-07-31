//
//  Representative.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/30/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import Foundation

struct Representative {
    
    // From Role API
    var state: String?
    var roleType: String?
    var leadershipTitle: String?
    var description: String?
    var district: String?
    var phoneNumber: String?
    var title: String?
    var website: String?
    var party: String?
    
    // From Person API
    var id: String?
    var firstName: String?
    var lastName: String?
    var twitterHandle: String?

    enum Type {
        case representative
        case sentator
    }
    
}