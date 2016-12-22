//  Datastore.swift
//  Kratos
//
//  Created by Dylan Straughan on 8/9/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import Foundation
import Locksmith

class Datastore {
    
    static let sharedDatastore = Datastore()
    
    var representatives: [Person]?
    var user: User?
    
    func getVotesFor(representative index: Int, at offset: Int, with limit: Int, onCompletion: (([LightTally]) -> Void)) {
        guard let representatives = representatives , index < representatives.count else {
            onCompletion([])
            return
        }
        let rep = representatives[index]
        if let tallies = rep.tallies , !tallies.isEmpty {
            var endLimit = 0
            if tallies.count > offset + limit {
                endLimit = offset + limit - 1
            } else {
                endLimit = tallies.count - 1
            }
            let returnArray = Array(tallies[offset...endLimit])
            onCompletion(returnArray)
        } else {
            onCompletion([])
        }
    }
}
