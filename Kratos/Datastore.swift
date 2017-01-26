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
    var user: User? {
        didSet {
            reloadRepresentatives()
        }
    }
    
    func reloadRepresentatives() {
        APIManager.getRepresentatives({ (success) in
           debugPrint("successful reload of representatives")
        }, failure: { (error) in
            debugPrint("could not get representative for User")
        })
    }
    
}
