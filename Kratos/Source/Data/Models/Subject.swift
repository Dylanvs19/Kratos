//
//  Subject.swift
//  Kratos
//
//  Created by Dylan Straughan on 5/6/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation

struct Subject: Decodable, Encodable, Equatable {
    
    static let identifier = "kratos_subjects"
    
    let name: String
    let id: Int
    
    init(name: String, id: Int) {
        self.name = name
        self.id = id
    }
    
    init?(json: JSONObject) {
        guard let name = json["name"] as? String,
              let id = json["id"] as? Int else { return nil }
        self.name = name
        self.id = id
    }
    
    func toJson() -> JSONObject {
        return ["name": self.name,
                "id": self.id]
    }
}

func ==(lhs: Subject, rhs: Subject) -> Bool {
    return lhs.id == rhs.id
}
func !=(lhs: Subject, rhs: Subject) -> Bool {
    return !(lhs == rhs)
}
