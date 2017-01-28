//
//  APIManager.swift
//  Kratos
//
//  Created by Dylan Straughan on 12/3/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import Foundation

struct APIManager {
    
    static func register(with password: String, user: User? = Datastore.shared.user, keyChainSuccess: @escaping (Bool) -> (), failure: @escaping (NetworkError) -> ()) {
        if let user = user {
            APIService.register(user, with: password, success: { (user) -> (Void) in
                Datastore.shared.user = user
                if let _ = user.token {
                    KeychainManager.create(user, success: { (didSucceed) in
                        keyChainSuccess(didSucceed)
                    })
                } else {
                    keyChainSuccess(false)
                }
            }, failure: { (error) -> (Void) in
                failure(error)
            })
        }
    }
    
    static func login(with email: String, and password: String, success: @escaping (Bool) -> (), failure: @escaping (NetworkError) -> ()) {
        APIService.logIn(with: email, password: password, success: { (user) in
            if let _ = user.token {
                KeychainManager.update(user, success: { (didSucceed) in
                    if !didSucceed {
                        debugPrint("KeychainManager update:_ not succeding")
                    }
                })
                Datastore.shared.user = user
                success(true)
            }
        }) { (error) in
            failure(error)
        }
    }
    
    static func forgotPassword(with email: String, success: @escaping (Bool) -> (), failure: @escaping (NetworkError) -> ()) {
        APIService.forgotPassword(with: email, success: { (successVar) in
            success(successVar)
        }) { (error) in
            failure(error)
        }
    }
    
    static func getFeedback(success: @escaping ([String]) -> (), failure: @escaping (NetworkError) -> ()) {
        APIService.fetchFeedback(success: { (questions) in
            success(questions)
        }) { (error) in
            failure(error)
        }
    }
    
    static func postFeedback(with answers: [String: String], success: @escaping (Bool) -> (), failure: @escaping (NetworkError) -> ()) {
        APIService.postFeedback(with: answers, success: { (successVal) in
            success(successVal)
        }, failure: { (error) in
            failure(error)
        })
    }
    
    static func updateUser(with user: User? = Datastore.shared.user, success: @escaping (Bool) -> (), failure: @escaping (NetworkError) -> ()) {
        if let user = user {
            APIService.update(with: user, success: { (user) -> (Void) in
                if let _ = KeychainManager.fetchToken() {
                    Datastore.shared.user = user
                    KeychainManager.update(user, success: { (didSucceed) in
                        success(didSucceed)
                    })
                } else {
                    success(false)
                    debugPrint("KeychainManager create:_ not succeding")
                }
            }, failure: { (error) -> (Void) in
                failure(error)
            })
        }
    }
    
    static func getUser(_ success: @escaping (Bool) -> (), failure: @escaping (NetworkError) -> ()) {
        if KeychainManager.fetchToken() != nil {
            APIService.fetchUser({ (user) in
                Datastore.shared.user = user
                success(true)
            }, failure: { (error) in
                failure(error)
            })
        }
    }
    
    //MARK: Representatives & Votes
    static func getRepresentatives(_ success: @escaping (Bool) -> (), failure: @escaping (NetworkError) -> ()) {
        if let user = Datastore.shared.user,
            let state = user.address?.state,
            let district = user.district {
            
            APIService.fetchRepresentatives(for: state, and: district, success: { (representativesArray) in
                DispatchQueue.main.async(execute: {
                    Datastore.shared.representatives = representativesArray
                    success(true)
                })
            }, failure: { (error) in
                failure(error)
            })
        }
    }
    
    static func getPerson(for personID: Int, success: @escaping (Person) -> (), failure: @escaping (NetworkError) -> ()) {
        APIService.fetchPerson(for: personID, success: { (person) in
            success(person)
        }, failure: { (error) in
            failure(error)
        })
    }
    
    static func getTallies(for personID: Int, nextPage: Int, success: @escaping (_ tallies: [LightTally]) -> (), failure: @escaping (NetworkError) -> ()) {
    
        APIService.fetchTallies(for: personID, with: nextPage, success: { (tallies) -> (Void) in
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
