//
//  UserService.swift
//  Kratos
//
//  Created by Dylan Straughan on 5/6/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import RxSwift

protocol UserService {
    
    func determineRecess() -> Observable<Bool>
    
    func fetchTrackedBills(for pageNumer: Int) -> Observable<[Bill]>
    func trackBill(billID: Int) -> Observable<Bill>
    func viewTrackedBill(billID: Int) -> Observable<Bill>
    func untrackBill(billID: Int) -> Observable<Void>
    
    func fetchTrackedSubjects() -> Observable<[Subject]>
    func followSubject(subjectID: Int) -> Observable<Void>
    func unfollowSubject(subjectID: Int) -> Observable<Void>
    
    //UserVotes
    func fetchUserVotingRecord() -> Observable<[LightTally]>
    func createUserVote(voteValue: VoteValue, tallyID: Int) -> Observable<LightTally>
    func fetchUserVote(tallyID: Int) -> Observable<LightTally>
    func updateUserVote(voteValue: VoteValue, tallyID: Int) -> Observable<LightTally>
    func deleteUserVote(tallyID: Int) -> Observable<Void>
}