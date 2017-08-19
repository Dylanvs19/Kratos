//
//  RepInfoViewModel.swift
//  Kratos
//
//  Created by Dylan Straughan on 6/25/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class RepInfoViewModel {
    
    let client: Client
    let loadStatus = Variable<LoadStatus>(.none)
    let disposeBag = DisposeBag()

    //State
    let state = Variable<RepInfoView.State>(.bio)
    
    let representative: Observable<Person>
    
    //Pagination
    var tallyPageCount = 1
    var sponsoredBillCount = 1
    
    var fetchAction = PublishSubject<Void>()

    //bioView
    let bio = Variable<String>("")
    let terms = Variable<[Term]>([])
    //votesView
    let tallies = Variable<[LightTally]>([])
    let formattedTallies = Variable<[Date: [[LightTally]]]>([:])
    //billsView
    let bills = Variable<[Bill]>([])
    let formattedBills = Variable<[Bill]>([])
    
    let contentOffset = Variable<CGFloat>(0)
    
    init(with client: Client, representative: Person) {
        self.client = client
        bio.value = representative.biography ?? ""
        terms.value = representative.terms ?? []
        self.representative = Observable.just(representative)
        bind()
        refreshData()
    }
    
    func refreshData() {
        state.value = .bills
        fetchAction.onNext(())
        state.value = .votes
        fetchAction.onNext(())
        state.value = .bio
    }
    
    func fetchTallies(for representative: Person) -> Observable<[LightTally]> {
        loadStatus.value = .loading
        return client.fetchTallies(personID: representative.id, pageNumber: tallyPageCount)
            .do(onNext: { [unowned self] _ in
                self.loadStatus.value = .none
                self.tallyPageCount += 1
                }, onError: { [unowned self] (error) in
                    let error = error as? KratosError ?? KratosError.unknown
                    self.loadStatus.value = .error(error: error)
            })
    }
    
    func fetchBills(for representative: Person) -> Observable<[Bill]> {
        loadStatus.value = .loading
        return client.fetchSponsoredBills(personID: representative.id, pageNumber: sponsoredBillCount)
            .do(onNext: { [unowned self] bills in
                self.loadStatus.value = .none
                self.sponsoredBillCount += 1
                }, onError: { [unowned self] (error) in
                    let error = error as? KratosError ?? KratosError.unknown
                    self.loadStatus.value = .error(error: error)
            })
    }
}

extension RepInfoViewModel: RxBinder {
    func bind() {
        
        let stateAndPerson = Observable.combineLatest(representative.asObservable(), state.asObservable())
        
        fetchAction.asObservable()
            .withLatestFrom(stateAndPerson.asObservable())
            .filter { $0.1 == .bills }
            .flatMap { self.fetchBills(for: $0.0) }
            .bind(to: bills)
            .disposed(by: disposeBag)
        
        fetchAction.asObservable()
            .withLatestFrom(stateAndPerson.asObservable())
            .filter { $0.1 == .votes }
            .flatMap { self.fetchTallies(for: $0.0)}
            .bind(to: tallies)
            .disposed(by: disposeBag)
        
        tallies.asObservable()
            .scan([], accumulator: +)
            .map { $0.groupBySection(groupBy: { $0.date?.computedDayFromDate ?? Date() }) }
            .map {
                var retVal = [Date: [[LightTally]]]()
                for (key, value) in $0 {
                    let dict = value.group(by: { $0.billID ?? 0 })
                    retVal[key] = dict
                }
                return retVal
            }
            .bind(to: formattedTallies)
            .disposed(by: disposeBag)
        
        bills.asObservable()
            .do(onNext: {
                print("\($0.count)")
            })
            .scan([], accumulator: +)
            .bind(to: formattedBills)
            .disposed(by: disposeBag)
    }
}
