//
//  Bill.swift
//  Kratos
//
//  Created by Dylan Straughan on 8/23/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import Foundation



struct Bill {
    var committees: [Committee]?
    
    init?(json: [String: AnyObject]) {

    }
    
}

struct Committee {
    var name: String?
    var id: Int?
    
}
