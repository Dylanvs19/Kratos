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
    
    func getDistrict() {
        if let streetAdress = streetAdress {
            APIClient().loadRepresentatives(from: streetAdress) { (representativesArray) -> (Void) in
                self.representatives = []
                var array : [Representative] = []
                for rep in representativesArray {
                    array.append((Representative(repDictionary: rep)))
                }
                self.representatives = array
            }
        }
    }
    
    func getLegislation(for representative: Representative) {

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