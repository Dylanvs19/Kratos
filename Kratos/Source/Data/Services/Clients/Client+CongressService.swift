//
//  Client+CongressService.swift
//  Kratos
//
//  Created by Dylan Straughan on 5/7/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import RxSwift

extension Client: CongressService {
    
    func determineRecess() -> Observable<Bool> {
        guard kratosClient.token != nil else { return Observable.error(KratosError.authError(error: .notLoggedIn)) }
        
        return request(.determineRecess)
            .toJson()
            .map {
                guard let boolDict = $0 as? [String: Bool],
                    let bool = boolDict["recess"] else {
                        throw KratosError.mappingError(type: .unexpectedValue)
                }
                return bool
            }
    }
    
    // Representatives
    func fetchRepresentatives(state: String, district: Int) -> Observable<[Person]> {
        guard kratosClient.token != nil else { return Observable.error(KratosError.authError(error: .notLoggedIn)) }
        
        return request(.fetchRepresentatives(state: state, district: district))
            .toJson()
            .mapArray(at: "data")
    }
    func fetchPerson(personID: Int) -> Observable<Person> {
        guard kratosClient.token != nil else { return Observable.error(KratosError.authError(error: .notLoggedIn)) }
        
        return request(.fetchPerson(personID: personID))
            .toJson()
            .mapObject()
    }
    func fetchTallies(personID: Int, pageNumber: Int) -> Observable<[LightTally]> {
        guard kratosClient.token != nil else { return Observable.error(KratosError.authError(error: .notLoggedIn)) }
        
        return request(.fetchTallies(personID: personID, pageNumber: pageNumber))
            .toJson()
            .map {
                guard let dict = $0 as? [String: Any],
                      let retVal = dict["data"] else {
                    throw KratosError.mappingError(type: .unexpectedValue)
                }
                return retVal
            }
            .softMapArray(at: "voting_record")
    }
    func fetchSponsoredBills(personID: Int, pageNumber: Int) -> Observable<[Bill]> {
        guard kratosClient.token != nil else { return Observable.error(KratosError.authError(error: .notLoggedIn)) }
        
        return request(.fetchSponsoredBills(personID: personID, pageNumber: pageNumber))
            .toJson()
            .softMapArray(at: "data")
    }
    
    //Vote
    func fetchTally(lightTallyID: Int) -> Observable<Tally> {
        guard kratosClient.token != nil else { return Observable.error(KratosError.authError(error: .notLoggedIn)) }
        
        return request(.fetchTally(lightTallyID: lightTallyID))
            .toJson()
            .mapObject()
    }
    
    //Bill
    func fetchAllBills(for pageNumber: Int) -> Observable<[Bill]> {
        guard kratosClient.token != nil else { return Observable.error(KratosError.authError(error: .notLoggedIn)) }
        
        return request(.fetchAllBills(pageNumber: pageNumber))
            .toJson()
            .softMapArray(at: "data")
    }

    func fetchBill(billID: Int) -> Observable<Bill> {
        guard kratosClient.token != nil else { return Observable.error(KratosError.authError(error: .notLoggedIn)) }
        
        return request(.fetchBill(billID: billID))
            .toJson()
            .mapObject()
    }

    func fetchBills(for subjects: [Subject], tracked: Bool, pageNumber: Int) -> Observable<[Bill]> {
        guard kratosClient.token != nil else { return Observable.error(KratosError.authError(error: .notLoggedIn)) }
        
        return request(.fetchBills(subjects: subjects, tracked: tracked, pageNumber: pageNumber))
            .toJson()
            .mapArray(at: "data")
    }
    
    //Bills on the floor
    func fetchOnFloor(with chamber: Chamber) -> Observable<[Bill]> {
        guard kratosClient.token != nil else { return Observable.error(KratosError.authError(error: .notLoggedIn)) }
        
        return request(.fetchOnFloor(chamber: chamber))
            .toJson()
            .mapArray(at: "data")
    }
    
    //Bills that are trending
    func fetchTrending() -> Observable<[Bill]> {
        guard kratosClient.token != nil else { return Observable.error(KratosError.authError(error: .notLoggedIn)) }
        return request(.fetchTrendingBills)
            .toJson()
            .mapArray(at: "data")
    }

    //Subjects
    func fetchAllSubjects(onlyActive: Bool = true) -> Observable<[Subject]> {
        guard kratosClient.token != nil else { return Observable.error(KratosError.authError(error: .notLoggedIn)) }
        
        guard let subjects = self.microStore.subjects.value else {
            return request(.fetchAllSubjects(onlyActive: onlyActive))
                .toJson()
                .mapArray(at: "data")
                .do(onNext: { [weak self] subjects in
                    self?.microStore.subjects.value = subjects
                })
        }
        return Observable.just(subjects)
    }
}
