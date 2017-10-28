//
//  Decodable.swift
//  Kratos
//
//  Created by Dylan Straughan on 5/5/17.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//

import Foundation

typealias JSONObject = [String: Any]

protocol Decodable {
    // initializes with Json
    init?(json: JSONObject)
}
