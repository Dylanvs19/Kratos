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
    
    static func updateUser(with user: User? = Datastore.sharedDatastore.user, onCompletion: @escaping (Bool) -> ()) {
        if let user = user {
            APIService.update(with: user, success: { (user) -> (Void) in
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
    
    static func getUser(_ onCompletion: @escaping (Bool) -> ()) {
        if let _ = Datastore.sharedDatastore.user?.token {
            APIService.fetchUser({ (user) in
                Datastore.sharedDatastore.user = user
                onCompletion(true)
            }, failure: { (error) in
                debugPrint(error)
                onCompletion(false)
            })
        }
    }
    
    //MARK: Representatives & Votes
    static func getRepresentatives(_ onCompletion: @escaping (Bool) -> ()) {
        if let user = Datastore.sharedDatastore.user,
            let state = user.address?.state,
            let district = user.district {
            
            APIService.fetchRepresentatives(for: state, and: district, success: { (representativesArray) in
                Datastore.sharedDatastore.representatives = representativesArray
                onCompletion(true)
            }, failure: { (error) in
                onCompletion(false)
            })
        }
    }
    
    static func getTallies(for representative: Person, nextPage: Int, success: @escaping (_ tallies: [LightTally]) -> (), failure: @escaping (NetworkError) -> ()) {
    
        APIService.fetchTallies(for: representative, with: nextPage, success: { (tallies) -> (Void) in
            success(tallies)
        }) { (error) -> (Void) in
            failure(error)
        }
    }
    
    static func getTally(for lightTally: LightTally, success: @escaping (Tally) -> (), failure: @escaping (NetworkError) -> ()) {
        
        APIService.fetchTally(for: lightTally, success: { (tally) -> (Void) in
            success(tally)
        }) { (error) -> (Void) in
            failure(error)
        }
    }
    
    static func getBill(for billId: Int, success: @escaping (Bill) -> (), failure: @escaping (NetworkError) -> ()) {
        
        APIService.fetchBill(from: billId, success: { (bill) -> (Void) in
            success(bill)
        }) { (error) -> (Void) in
            failure(error)
        }
    }
    
    static func getUserVotingRecord(success: @escaping ([LightTally]) -> (), failure: @escaping (NetworkError) -> ()) {
        APIService.fetchUserVotingRecord(success: { (lightTallies) -> (Void) in
            success(lightTallies)
        }) { (error) -> (Void) in
            failure(error)
        }
    }
    
    static func createUserTally(with voteValue:VoteValue, and tallyID: Int, success: @escaping (LightTally) -> (), failure: @escaping (NetworkError) -> ()) {
        APIService.createUserTally(with: voteValue, tallyID: tallyID, success: { (tally) -> (Void) in
            success(tally)
        }) { (error) -> (Void) in
            failure(error)
        }
    }
    
    static func getUserTally(with tallyID: Int, success: @escaping (LightTally) -> (), failure: @escaping (NetworkError) -> ()) {
        APIService.fetchUserTally(tallyID: tallyID, success: { (tally) -> (Void) in
            success(tally)
        }) { (error) -> (Void) in
            failure(error)
        }
    }
    
    static func updateUserTally(with voteValue:VoteValue, and tallyID: Int, success: @escaping (LightTally) -> (), failure: @escaping (NetworkError) -> ()) {
        APIService.updateUserTally(with: voteValue, tallyID: tallyID, success: { (tally) -> (Void) in
            success(tally)
        }) { (error) -> (Void) in
            failure(error)
        }
    }
    
    static func deleteUserTally(with tallyID: Int, success: @escaping (Bool) -> (), failure: @escaping (NetworkError) -> ()) {
        APIService.deleteUserTally(tallyID: tallyID, success: { (didSucceed) -> (Void) in
            success(didSucceed)
        }) { (error) -> (Void) in
            failure(error)
        }
    }
    
    static func postKratosAnalyticEvent(event: KratosAnalytics.ContactAnalyticType, success: @escaping (Bool) -> (), failure: @escaping (NetworkError) -> ()) {
        APIService.postKratosAnalyticEvent(with: event, success: { (didSucceed) -> (Void) in
            success(didSucceed)
        }) { (error) -> (Void) in
            failure(error)
        }
    }
}
