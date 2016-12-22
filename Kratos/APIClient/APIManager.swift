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
                debugPrint(error)
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
            debugPrint(error)
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
    
    static func getVotes(for representative: Person, success: @escaping ([LightTally]) -> (), failure: (NetworkError) -> Void?) {
    
        APIService.loadVotes(for: representative, success: { (tallies) in
                success(tallies)
        }, failure:  { _ in
            success([])
        })
    }
}
