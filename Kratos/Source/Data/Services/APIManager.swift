//
//  APIManager.swift
//  Kratos
//
//  Created by Dylan Straughan on 12/3/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import Foundation

struct APIManager {
    
    //MARK: Sign In
    
    static func register(with password: String, user: User? = Datastore.shared.user, keyChainSuccess: @escaping (Bool) -> (), failure: @escaping (KratosError) -> ()) {
        if let user = user {
            APIService.register(user, with: password, success: { (user) -> (Void) in
                Datastore.shared.user = user
                if let token = user.token {
                   // KeychainManager.create(token, success: { (didSucceed) in
                        keyChainSuccess(true)
                    //})
                } else {
                    keyChainSuccess(false)
                }
            }, failure: { (error) -> (Void) in
                failure(error)
            })
        }
    }
    
    static func login(with email: String, and password: String, success: @escaping (Bool) -> (), failure: @escaping (KratosError) -> ()) {
        APIService.logIn(with: email, password: password, success: { (user) in
            if let token = user.token {
                //KeychainManager.update(token, success: { (didSucceed) in
                 //   if !didSucceed {
                        debugPrint("KeychainManager update:_ not succeding")
                 //   }
                //})
                Datastore.shared.user = user
                success(true)
            }
        }) { (error) in
            failure(error)
        }
    }
    
    static func forgotPassword(with email: String, success: @escaping (Bool) -> (), failure: @escaping (KratosError) -> ()) {
        APIService.forgotPassword(with: email, success: { (successVar) in
            success(successVar)
        }) { (error) in
            failure(error)
        }
    }
    
    //MARK: Feedback
    
    static func getFeedback(success: @escaping ([String]) -> (), failure: @escaping (KratosError) -> ()) {
        APIService.fetchFeedback(success: { (questions) in
            success(questions)
        }) { (error) in
            failure(error)
        }
    }
    
    static func postFeedback(with answers: [String: String], success: @escaping (Bool) -> (), failure: @escaping (KratosError) -> ()) {
        APIService.postFeedback(with: answers, success: { (successVal) in
            success(successVal)
        }, failure: { (error) in
            failure(error)
        })
    }
    
    //MARK: User
    
    static func updateUser(with user: User? = Datastore.shared.user, success: @escaping (Bool) -> (), failure: @escaping (KratosError) -> ()) {
        if let user = user {
            APIService.update(with: user, success: { (user) -> (Void) in
                if let token = KeychainManager.token {
                    Datastore.shared.user = user
                    //KeychainManager.update(token, success: { (didSucceed) in
                        success(true)
                    //})
                } else {
                    success(false)
                    debugPrint("KeychainManager create:_ not succeding")
                }
            }, failure: { (error) -> (Void) in
                failure(error)
            })
        }
    }
    
    static func getUser(_ success: @escaping (Bool) -> (), failure: @escaping (KratosError) -> ()) {
        if KeychainManager.token != nil {
            APIService.fetchUser({ (user) in
                Datastore.shared.user = user
                success(true)
            }, failure: { (error) in
                failure(error)
            })
        }
    }
    
    static func getUserVotingRecord(success: @escaping ([LightTally]) -> (), failure: @escaping (KratosError) -> ()) {
        APIService.fetchUserVotingRecord(success: { (lightTallies) -> (Void) in
            success(lightTallies)
        }) { (error) -> (Void) in
            failure(error)
        }
    }
    
    static func createUserTally(with voteValue:VoteValue, and tallyID: Int, success: @escaping (LightTally) -> (), failure: @escaping (KratosError) -> ()) {
        APIService.createUserTally(with: voteValue, tallyID: tallyID, success: { (tally) -> (Void) in
            success(tally)
        }) { (error) -> (Void) in
            failure(error)
        }
    }
    
    static func getUserTally(with tallyID: Int, success: @escaping (LightTally) -> (), failure: @escaping (KratosError) -> ()) {
        APIService.fetchUserTally(tallyID: tallyID, success: { (tally) -> (Void) in
            success(tally)
        }) { (error) -> (Void) in
            failure(error)
        }
    }
    
    static func updateUserTally(with voteValue:VoteValue, and tallyID: Int, success: @escaping (LightTally) -> (), failure: @escaping (KratosError) -> ()) {
        APIService.updateUserTally(with: voteValue, tallyID: tallyID, success: { (tally) -> (Void) in
            success(tally)
        }) { (error) -> (Void) in
            failure(error)
        }
    }
    
    static func deleteUserTally(with tallyID: Int, success: @escaping (Bool) -> (), failure: @escaping (KratosError) -> ()) {
        APIService.deleteUserTally(tallyID: tallyID, success: { (didSucceed) -> (Void) in
            success(didSucceed)
        }) { (error) -> (Void) in
            failure(error)
        }
    }
    
    //MARK: Representatives 
    
    static func getRepresentatives(_ success: @escaping (Bool) -> (), failure: @escaping (KratosError) -> ()) {
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
    
    static func getPerson(for personID: Int, success: @escaping (Person) -> (), failure: @escaping (KratosError) -> ()) {
        APIService.fetchPerson(for: personID, success: { (person) in
            success(person)
        }, failure: { (error) in
            failure(error)
        })
    }
    
    //MARK: Tallies
    
    static func getTallies(for personID: Int, nextPage: Int, success: @escaping (_ tallies: [LightTally]) -> (), failure: @escaping (KratosError) -> ()) {
    
        APIService.fetchTallies(for: personID, with: nextPage, success: { (tallies) -> (Void) in
            success(tallies)
        }) { (error) -> (Void) in
            failure(error)
        }
    }
    
    static func getTally(for lightTallyID: Int, success: @escaping (Tally) -> (), failure: @escaping (KratosError) -> ()) {
        
        APIService.fetchTally(for: lightTallyID, success: { (tally) -> (Void) in
            success(tally)
        }) { (error) -> (Void) in
            failure(error)
        }
    }
    
    //MARK: Bills
    
    static func getBill(for billId: Int, success: @escaping (Bill) -> (), failure: @escaping (KratosError) -> ()) {
        
        APIService.fetchBill(from: billId, success: { (bill) -> (Void) in
            success(bill)
        }) { (error) -> (Void) in
            failure(error)
        }
    }
    
    static func getBills(for personID: Int, nextPage: Int, success: @escaping ([Bill]) -> (), failure: @escaping (KratosError) -> ()) {
        APIService.fetchSponsoredBills(for: personID, with: nextPage, success: { (bills) -> (Void) in
            success(bills)
        }) { (error) -> (Void) in
            failure(error)
        }
    }
    
    static func postKratosAnalyticEvent(event: KratosAnalytics.ContactAnalyticType, success: @escaping (Bool) -> (), failure: @escaping (KratosError) -> ()) {
        APIService.postKratosAnalyticEvent(with: event, success: { (didSucceed) -> (Void) in
            success(didSucceed)
        }) { (error) -> (Void) in
            failure(error)
        }
    }
}
