//  Datastore.swift
//  Kratos
//
//  Created by Dylan Straughan on 8/9/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import Foundation
import Locksmith

class Datastore {
    
    static let shared = Datastore()
    
    var representatives = [Person]()
    var temporaryRepresentatives = [Person]()
    var user: User?
    
}
