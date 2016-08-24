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
            if let reps = representatives {
                determineDistrictNumber(from: reps)
                
            }
        }
    }
    var streetAdress: StreetAddress?
    
    func getDistrict( onCompletion: (Bool) -> (Void)) {
        if let streetAdress = streetAdress {
            APIClient().loadRepresentatives(from: streetAdress, success: { (representativesArray) -> (Void) in
                self.representatives = []
                var array : [Representative] = []
                for repDict in representativesArray {
                    var rep = Representative(json: repDict)
                    APIClient().loadVotes(for: rep, success: { (votes) -> (Void) in
                        rep.votes = votes
                        array.append(rep)
                        }, failure: { (error) in
                            array.append(rep)
                    })
                }
                self.representatives = array
                onCompletion(true)
                }, failure: { (error) in
                    onCompletion(false)
            })
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