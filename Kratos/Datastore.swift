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
    
    var representatives: [DetailedRepresentative]?
    var user: User?
    
    func getVotesFor(representative index: Int, at offset: Int, with limit: Int, onCompletion: (([Vote]) -> Void)) {
        guard let representatives = representatives , index < representatives.count else {
            onCompletion([])
            return
        }
        let rep = representatives[index]
        if let votes = rep.votes , !votes.isEmpty {
            var endLimit = 0
            if votes.count > offset + limit {
                endLimit = offset + limit - 1
            } else {
                endLimit = votes.count - 1
            }
            let returnArray = Array(votes[offset...endLimit])
            onCompletion(returnArray)
        } else {
            onCompletion([])
        }
    }
}
