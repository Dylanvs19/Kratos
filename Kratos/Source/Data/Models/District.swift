//
//  StateDistrictModel.swift
//  Kratos
//
//  Created by Dylan Straughan on 11/30/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation

struct District: JSONDecodable {
    let state: State
    let district: Int
    
    init(state: State, district: Int) {
        self.state = state
        self.district = district
    }
    
    init?(json: JSONObject) {
        guard let stateString = json["state"] as? String,
              let state = State(rawValue: stateString),
              let district = json["district"] as? Int else { return nil }
        self.state = state
        self.district = district
    }
}

func == (lhs: District, rhs: District) -> Bool {
    return lhs.state.rawValue == rhs.state.rawValue && lhs.district == rhs.district
}

func != (lhs: District, rhs: District) -> Bool {
    return !(lhs == rhs)
}
