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
    
    //Pagination
    var tallyPageCount = 1
    var sponsoredBillCount = 1
    
    //State
    let state = Variable<RepInfoView.State>(.bio)
    
    let representative: Observable<Person>
    
    //bioView
    let bio = Variable<String>("")
    let terms = Variable<[Term]>([])
    //votesView
    fileprivate let _tallies = Variable<[LightTally]>([])
    let tallies = Variable<[Int: [Int: Set<LightTally>]]>([:])
    //billsView
    fileprivate let _bills = Variable<[Bill]>([])
    let bills = Variable<[Bill]>([])
    
    let fetchAction = PublishSubject<Void>()
    let contentOffset = Variable<CGFloat>(0)
    
    let disposeBag = DisposeBag()
    
    init(with client: Client, representative: Person, contentOffset: Variable<CGFloat>) {
        self.client = client
        bio.value = representative.biography ?? ""
        terms.value = representative.terms ?? []
        self.representative = Observable.just(representative)
        bind()
        initialLoad()
        //Bind up
        self.contentOffset.asObservable()
            .bind(to: contentOffset)
            .disposed(by: disposeBag)
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
                print("\(bills.count)")
                self.loadStatus.value = .none
                self.sponsoredBillCount += 1
                }, onError: { [unowned self] (error) in
                    let error = error as? KratosError ?? KratosError.unknown
                    self.loadStatus.value = .error(error: error)
            })
    }
    
    func initialLoad() {
        state.value = .votes
        fetchAction.onNext(())
        state.value = .bills
        fetchAction.onNext(())
        state.value = .bio
    }
}

extension RepInfoViewModel: RxBinder {
    func bind() {
        
        let stateAndPerson = Observable.combineLatest(representative.asObservable(), state.asObservable())
        
        fetchAction.asObservable()
            .withLatestFrom(stateAndPerson.asObservable())
            .filter { $0.1 == .bills }
            .flatMap { self.fetchBills(for: $0.0) }
            .bind(to: _bills)
            .disposed(by: disposeBag)
        
        fetchAction.asObservable()
            .withLatestFrom(stateAndPerson.asObservable())
            .filter { $0.1 == .votes }
            .flatMap { self.fetchTallies(for: $0.0)}
            .bind(to: _tallies)
            .disposed(by: disposeBag)
        
        _tallies.asObservable()
            .scan([], accumulator: +)
            .map { $0.groupBySection(groupBy: { $0.date?.computedDayFromDate ?? Date() }) }
            .map {
                var retVal = [Int: [Int: Set<LightTally>]]()
                for (key, value) in $0 {
                    retVal[key] = value.uniqueGroupBySection(groupBy: { $0.billOfficialTitle ?? "" })
                }
                return retVal
            }
            .bind(to: tallies)
            .disposed(by: disposeBag)
        
        _bills.asObservable()
            .scan([], accumulator: +)
            .bind(to: bills)
            .disposed(by: disposeBag)
    }
}
