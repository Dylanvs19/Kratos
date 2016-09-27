//
//  Datastore.swift
//  Kratos
//
//  Created by Dylan Straughan on 8/9/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import Foundation

class Datastore {
    
    static let sharedDatastore = Datastore()
    
    var representatives: [Representative]? {
        didSet {
            if representatives != nil && user?.district == nil {
                determineDistrictNumber(from: representatives!)
            }
        }
    }
    var streetAdress: StreetAddress?
    var user: User?
    
    func getDistrict( onCompletion: (Bool) -> (Void)) {
        if let streetAdress = streetAdress {
            APIClient.loadRepresentatives(from: streetAdress, success: { (representativesArray) in
                self.representatives = []
                var array : [Representative] = []
                for repDict in representativesArray {
                    array.append(Representative(json: repDict))
                }
                self.representatives = array
                onCompletion(true)
                }, failure: { (error) in
                    onCompletion(false)
            })
        }
    }
    
    func getVotesForRepresentatives(success: (Bool) -> ()) {
        if let representatives = representatives {
            for (index, rep) in representatives.enumerate() {
                APIClient.loadVotes(for: rep, success: { (votes) in
                    self.representatives![index].votes = votes
                    if self.representatives![0].votes != nil &&
                       self.representatives![1].votes != nil &&
                       self.representatives![2].votes != nil {
                        success(true)
                    }
                    }, failure: { (error) in
                        success(false)
                })
            }
        }
    }
    
    func determineDistrictNumber(from repArray: [Representative]) {
        for rep in repArray {
            if rep.type == .representative {
                if let district = rep.district {
                    streetAdress?.district = district
                }
            }
        }
    }
}