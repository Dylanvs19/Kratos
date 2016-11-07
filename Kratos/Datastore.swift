//
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
    
    //MARK: Registration
    func register(with password: String, onCompletion: @escaping (Bool) -> ()) {
        if let user = user {
            APIClient.register(user, with: password, success: { (user) -> (Void) in
                if let _ = user.token {
                    self.user = user
                    KeychainManager.create(user, success: { (success) in
                        onCompletion(success)
                    })
                } else {
                    onCompletion(false)
                }
                }, failure: { (error) -> (Void) in
                    debugPrint(error ?? "registerWith Failure")
                    onCompletion(false)
            })
        }
    }
    
    func login(with phone: Int, and password: String, onCompletion: @escaping (Bool) -> ()) {
        APIClient.logIn(with: phone, password: password, success: { (user) in
            if let _ = user.token {
                KeychainManager.update(user, success: { (success) in
                    if !success {
                        print ("KeychainManager update:_ not succeding")
                    }
                })
                self.user = user
                onCompletion(true)
            }
            }) { (error) in
                debugPrint(error ?? "loginWith Failure")
                onCompletion(false)
        }
    }
    
    func getUser(_ onCompletion: @escaping (Bool) -> ()) {
        if let _ = user?.token {
            APIClient.fetchUser({ (user) in
                self.user = user
                onCompletion(true)
                }, failure: { (error) in
                    debugPrint(error ?? "get User Failure")
                    onCompletion(false)
            })
        }
    }
    
    //MARK: Representatives & Votes
    func getRepresentatives(_ onCompletion: @escaping (Bool) -> ()) {
        if let user = user,
            let state = user.streetAddress?.state,
            let district = user.district {
            
            APIClient.loadRepresentatives(for: state, and: district, success: { (representativesArray) in
                self.representatives = representativesArray
                onCompletion(true)
                }, failure: { (error) in
                    onCompletion(false)
            })
        }
    }
    
    func getVotesForRepresentatives(_ success: @escaping (Bool) -> ()) {
        if let representatives = representatives , representatives.count == 3 {
            for (index, rep) in representatives.enumerated() {
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
}
