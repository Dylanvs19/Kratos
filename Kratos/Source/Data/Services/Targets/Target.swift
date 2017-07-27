//
//  Target.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/26/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import Alamofire

protocol Target {
    //Path of target resource
    var path: String { get }
    // HTTP Method interacting with resource
    var method: Alamofire.HTTPMethod { get }
    //Parameters associated with request
    var parameters: JSONObject? { get }
}
