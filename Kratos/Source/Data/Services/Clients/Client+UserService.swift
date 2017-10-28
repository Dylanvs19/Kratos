//
//  Client+UserService.swift
//  Kratos
//
//  Created by Dylan Straughan on 5/7/17.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//

import Foundation
import RxSwift

extension Client: UserService {
    
    func fetchTrackedBills(for pageNumer: Int, ignoreCache: Bool = false) -> Observable<[Bill]> {
        guard kratosClient.token != nil else { return Observable.error(KratosError.authError(error: .notLoggedIn)) }
        
        return request(.fetchTrackedBills(pageNumber: pageNumer), ignoreCache: ignoreCache)
            .toJson()
            .mapArray(at: "data")
    }
    
    func fetchTrackedBillIds() -> Observable<[Int]> {
        guard kratosClient.token != nil else { return Observable.error(KratosError.authError(error: .notLoggedIn)) }
        
        return request(.fetchTrackedBillIds, ignoreCache: true)
            .toJson()
            .map {
                guard let json = $0 as? [String: Any],
                    let ints = json["data"] as? [Int] else { throw KratosError.mappingError(type: .unexpectedValue) }
                return ints
        }
    }
    
    func trackBill(billID: Int) -> Observable<[Int]> {
        guard kratosClient.token != nil else { return Observable.error(KratosError.authError(error: .notLoggedIn)) }
        
        return request(.trackBill(billID: billID), ignoreCache: true)
            .toJson()
            .map {
                guard let json = $0 as? [String: Any],
                    let ints = json["data"] as? [Int] else { throw KratosError.mappingError(type: .unexpectedValue) }
                return ints
            }
    }
    
    func viewTrackedBill(billID: Int) -> Observable<Bill> {
        guard kratosClient.token != nil else { return Observable.error(KratosError.authError(error: .notLoggedIn)) }
        
        return request(.viewTrackedBill(billID: billID))
            .toJson()
            .mapObject()
    }
    
    func untrackBill(billID: Int) -> Observable<Void> {
        guard kratosClient.token != nil else { return Observable.error(KratosError.authError(error: .notLoggedIn)) }
        
        return request(.untrackBill(billID: billID), ignoreCache: true)
            .map { _ in return () }
    }
    
    func fetchTrackedSubjects(ignoreCache: Bool = false) -> Observable<[Subject]> {
        guard kratosClient.token != nil else { return Observable.error(KratosError.authError(error: .notLoggedIn)) }
        
        return request(.fetchTrackedSubjects, ignoreCache: ignoreCache)
            .toJson()
            .mapArray(at: "data")
    }
    
    func followSubject(subjectID: Int) -> Observable<Void> {
        guard kratosClient.token != nil else { return Observable.error(KratosError.authError(error: .notLoggedIn)) }
        
        return request(.followSubject(subjectID: subjectID), ignoreCache: true)
            .map { _ in return () }
    }

    func unfollowSubject(subjectID: Int) -> Observable<Void> {
        guard kratosClient.token != nil else { return Observable.error(KratosError.authError(error: .notLoggedIn)) }
        
        return request(.unfollowSubject(subjectID: subjectID), ignoreCache: true)
            .map { _ in return () }
    }
    
    //UserVotes
    func fetchUserVotingRecord() -> Observable<[LightTally]> {
        guard kratosClient.token != nil else { return Observable.error(KratosError.authError(error: .notLoggedIn)) }
        
        return request(.fetchUserVotingRecord)
            .toJson()
            .mapArray()
    }
    
    func createUserVote(voteValue: VoteValue, tallyID: Int) -> Observable<LightTally> {
        guard kratosClient.token != nil else { return Observable.error(KratosError.authError(error: .notLoggedIn)) }
        
        return request(.createUserVote(voteValue: voteValue, tallyID: tallyID))
            .toJson()
            .mapObject()
    }
    
    func fetchUserVote(tallyID: Int) -> Observable<LightTally> {
        guard kratosClient.token != nil else { return Observable.error(KratosError.authError(error: .notLoggedIn)) }
        
        return request(.fetchUserVote(tallyID: tallyID))
            .toJson()
            .mapObject()
    }
    
    func updateUserVote(voteValue: VoteValue, tallyID: Int) -> Observable<LightTally> {
        guard kratosClient.token != nil else { return Observable.error(KratosError.authError(error: .notLoggedIn)) }
        
        return request(.updateUserVote(voteValue: voteValue, tallyID: tallyID), ignoreCache: true)
            .toJson()
            .mapObject()
    }
    
    func deleteUserVote(tallyID: Int) -> Observable<Void> {
        guard kratosClient.token != nil else { return Observable.error(KratosError.authError(error: .notLoggedIn)) }
        
        return request(.deleteUserVote(tallyID: tallyID), ignoreCache: true)
            .map { _ in return () }
    }
}
