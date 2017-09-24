//
//  CongressService.swift
//  Kratos
//
//  Created by Dylan Straughan on 5/6/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import RxSwift

protocol CongressService {
    
    func determineRecess() -> Observable<Bool>
    
    // Representatives
    func fetchRepresentatives(state: String, district: Int) -> Observable<[Person]>
    func fetchPerson(personID: Int) -> Observable<Person>
    func fetchTallies(personID: Int, pageNumber: Int) -> Observable<[LightTally]>
    func fetchSponsoredBills(personID: Int, pageNumber: Int) -> Observable<[Bill]>
    
    //Vote
    func fetchTally(lightTallyID: Int) -> Observable<Tally>
    
    //Bill
    func fetchAllBills(for pageNumber: Int) -> Observable<[Bill]>
    func fetchBill(billID: Int) -> Observable<Bill>
    func fetchBills(for subjects: [Subject], tracked: Bool, pageNumber: Int) -> Observable<[Bill]>
    
    //Bills on the floor
    func fetchOnFloor(with chamber: Chamber) -> Observable<[Bill]>
    func fetchTrending() -> Observable<[Bill]> 
    
    //Subjects
    func fetchAllSubjects(onlyActive: Bool) -> Observable<[Subject]>
    
}
