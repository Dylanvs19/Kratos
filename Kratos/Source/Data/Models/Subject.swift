//
//  Subject.swift
//  Kratos
//
//  Created by Dylan Straughan on 5/6/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation

struct Subject: Decodable {
    var name: String
    var id: Int
    
    init?(json: [String: Any]) {
        guard let name = json["name"] as? String,
              let id = json["id"] as? Int else { return nil }
        self.name = name
        self.id = id
    }
    
}
