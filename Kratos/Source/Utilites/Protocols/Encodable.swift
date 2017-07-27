//
//  Encodable.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/26/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation

protocol Encodable {
    func toJson() -> JSONObject
}
