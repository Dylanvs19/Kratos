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
        return request(.fetchRepresentatives(state: state, district: district))
            .toJson()
            .mapArray(at: "data")
    }
    func fetchPerson(personID: Int) -> Observable<Person> {
        return request(.fetchPerson(personID: personID))
            .toJson()
            .mapObject()
    }
    func fetchTallies(personID: Int, pageNumber: Int) -> Observable<[LightTally]> {
        return request(.fetchTallies(personID: personID, pageNumber: pageNumber))
            .toJson()
            .mapArray(at: "data")
    }
    func fetchSponsoredBills(personID: Int, pageNumber: Int) -> Observable<[Bill]> {
        return request(.fetchTallies(personID: personID, pageNumber: pageNumber))
            .toJson()
            .mapArray(at: "data")
    }
    
    //Vote
    func fetchTally(lightTallyID: Int) -> Observable<Tally> {
        return request(.fetchTally(lightTallyID: lightTallyID))
            .toJson()
            .mapObject()
    }
    
    //Bill
    func fetchAllBills(for pageNumber: Int) -> Observable<[Bill]> {
        return request(.fetchAllBills(pageNumber: pageNumber))
            .toJson()
            .mapArray(at: "data")
    }

    func fetchBill(billID: Int) -> Observable<Bill> {
        return request(.fetchBill(billID: billID))
            .toJson()
            .mapObject()
    }

    func fetchBills(subjects: [Int], pageNumber: Int) -> Observable<[Bill]> {
        return request(.fetchBills(subjects: subjects, pageNumber: pageNumber))
            .toJson()
            .mapArray(at: "data")
    }

    //Subjects
    func fetchAllSubjects() -> Observable<[Subject]> {
        return request(.fetchAllSubjects)
            .toJson()
            .mapArray(at: "data")
    }
}
