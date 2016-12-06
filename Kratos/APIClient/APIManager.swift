//
//  APIManager.swift
//  Kratos
//
//  Created by Dylan Straughan on 12/3/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import Foundation

struct APIManager {
    
    static func register(with password: String, user: User? = Datastore.sharedDatastore.user, onCompletion: @escaping (Bool) -> ()) {
        if let user = user {
            APIService.register(user, with: password, success: { (user) -> (Void) in
                if let _ = user.token {
                    Datastore.sharedDatastore.user = user
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
    
    static func login(with phone: Int, and password: String, onCompletion: @escaping (Bool) -> ()) {
        APIService.logIn(with: phone, password: password, success: { (user) in
            if let _ = user.token {
                KeychainManager.update(user, success: { (success) in
                    if !success {
                        print ("KeychainManager update:_ not succeding")
                    }
                })
                Datastore.sharedDatastore.user = user
                onCompletion(true)
            }
        }) { (error) in
            debugPrint(error ?? "loginWith Failure")
            onCompletion(false)
        }
    }
    
    static func getUser(_ onCompletion: @escaping (Bool) -> ()) {
        if let _ = Datastore.sharedDatastore.user?.token {
            APIService.fetchUser({ (user) in
                Datastore.sharedDatastore.user = user
                onCompletion(true)
            }, failure: { (error) in
                debugPrint(error ?? "get User Failure")
                onCompletion(false)
            })
        }
    }
    
    //MARK: Representatives & Votes
    static func getRepresentatives(_ onCompletion: @escaping (Bool) -> ()) {
        if let user = Datastore.sharedDatastore.user,
            let state = user.streetAddress?.state,
            let district = user.district {
            
            APIService.loadRepresentatives(for: state, and: district, success: { (representativesArray) in
                Datastore.sharedDatastore.representatives = representativesArray
                onCompletion(true)
            }, failure: { (error) in
                onCompletion(false)
            })
        }
    }
    
    static func getVotesForRepresentatives(_ success: @escaping (Bool) -> ()) {
        
        // This is not great - and will not work in places with only a rep & no senators. Should Refactor
        
        if let representatives = Datastore.sharedDatastore.representatives , representatives.count == 3 {
            for (index, rep) in representatives.enumerated() {
                APIService.loadVotes(for: rep, success: { (votes) in
                    Datastore.sharedDatastore.representatives![index].votes = votes
                    if Datastore.sharedDatastore.representatives![0].votes != nil &&
                       Datastore.sharedDatastore.representatives![1].votes != nil &&
                       Datastore.sharedDatastore.representatives![2].votes != nil {
                        success(true)
                    }
                }, failure: { (error) in
                    success(false)
                })
            }
        }
    }
}
