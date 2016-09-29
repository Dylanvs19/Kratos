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
    
    var representatives: [Representative]?
    var user: User?
    
    //MARK: Registration
    func registerWith(password: String, onCompletion: (Bool) -> ()) {
        if let user = user {
            APIClient.register(user, with: password, success: { (user) -> (Void) in
                if let _ = user.token {
                    do{
                        try user.createInSecureStore()
                    } catch {
                        onCompletion(false)
                    }
                    self.user = user
                    onCompletion(true)
                }
                onCompletion(false)
                }, failure: { (error) -> (Void) in
                    debugPrint(error)
                    onCompletion(false)
            })
        }
    }
    
    func loginWith(phone: Int, and password: String, onCompletion: (Bool) -> ()) {
        APIClient.logIn(with: phone, password: password, success: { (user) in
            if let _ = user.token {
                do{
                    try user.updateInSecureStore()
                } catch {
                    onCompletion(false)
                }
                self.user = user
                onCompletion(true)
            }
            }) { (error) in
                debugPrint(error)
                onCompletion(false)
        }
    }
    
    func getUser(onCompletion: (Bool) -> ()) {
        if let _ = user?.token {
            APIClient.fetchUser({ (user) in
                self.user = user
                onCompletion(true)
                }, failure: { (error) in
                    debugPrint(error)
                    onCompletion(false)
            })
        }
    }
    
    //MARK: Representatives & Votes
    func getRepresentatives(onCompletion: (Bool) -> ()) {
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
    
    func getVotesForRepresentatives(success: (Bool) -> ()) {
        if let representatives = representatives where representatives.count == 3 {
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

}
