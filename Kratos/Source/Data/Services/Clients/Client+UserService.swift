//
//  Client+UserService.swift
//  Kratos
//
//  Created by Dylan Straughan on 5/7/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import RxSwift

extension Client: UserService {
    
    func fetchTrackedBills(for pageNumer: Int) -> Observable<[Bill]> {
        return request(.fetchTrackedBills(pageNumber: pageNumer))
            .toJson()
            .mapArray(at: "data")
    }
    
    func fetchTrackedBillIds() -> Observable<[Int]> {
        return request(.fetchTrackedBillIds, ignoreCache: true)
            .toJson()
            .map {
                guard let json = $0 as? [String: Any],
                    let ints = json["data"] as? [Int] else { throw KratosError.mappingError(type: .unexpectedValue) }
                return ints
        }
    }
    
    func trackBill(billID: Int) -> Observable<[Int]> {
        return request(.trackBill(billID: billID))
            .toJson()
            .map {
                guard let json = $0 as? [String: Any],
                    let ints = json["data"] as? [Int] else { throw KratosError.mappingError(type: .unexpectedValue) }
                return ints
            }
    }
    
    func viewTrackedBill(billID: Int) -> Observable<Bill> {
        return request(.viewTrackedBill(billID: billID))
            .toJson()
            .mapObject()
    }
    
    func untrackBill(billID: Int) -> Observable<Void> {
        return request(.untrackBill(billID: billID))
            .map { _ in return () }
    }
    
    func fetchTrackedSubjects() -> Observable<[Subject]> {
        return request(.fetchTrackedSubjects)
            .toJson()
            .mapArray(at: "data")
    }
    
    func followSubject(subjectID: Int) -> Observable<Void> {
        return request(.followSubject(subjectID: subjectID))
            .map { _ in return () }
    }

    func unfollowSubject(subjectID: Int) -> Observable<Void> {
        return request(.unfollowSubject(subjectID: subjectID))
            .map { _ in return () }
    }
    
    //UserVotes
    func fetchUserVotingRecord() -> Observable<[LightTally]> {
        return request(.fetchUserVotingRecord)
            .toJson()
            .mapArray()
    }
    
    func createUserVote(voteValue: VoteValue, tallyID: Int) -> Observable<LightTally> {
        return request(.createUserVote(voteValue: voteValue, tallyID: tallyID))
            .toJson()
            .mapObject()
    }
    
    func fetchUserVote(tallyID: Int) -> Observable<LightTally> {
        return request(.fetchUserVote(tallyID: tallyID))
            .toJson()
            .mapObject()
    }
    
    func updateUserVote(voteValue: VoteValue, tallyID: Int) -> Observable<LightTally> {
        return request(.updateUserVote(voteValue: voteValue, tallyID: tallyID))
            .toJson()
            .mapObject()
    }
    
    func deleteUserVote(tallyID: Int) -> Observable<Void> {
        return request(.deleteUserVote(tallyID: tallyID))
            .map { _ in return () }
    }
}
