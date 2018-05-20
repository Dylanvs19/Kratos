//
//  RepInfoViewModel.swift
//  Kratos
//
//  Created by Dylan Straughan on 6/25/17.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import SwiftDate

class RepInfoViewModel {
    
    // MARK - Variables -
    let client: CongressService
    let loadStatus = Variable<LoadStatus>(.loading)
    let disposeBag = DisposeBag()

    //State
    let state = Variable<RepInfoView.State>(.bio)
    
    let representative = Variable<Person?>(nil)
    
    //Pagination
    var tallyPageCount = 1
    var sponsoredBillCount = 1
    
    var fetchAction = PublishSubject<Void>()

    //bioView
    let bio = Variable<String>("")
    let terms = Variable<[Term]>([])
    //votesView
    let tallies = Variable<[LightTally]>([])
    let formattedTallies = Variable<[[[LightTally]]]>([[[]]])
    //billsView
    let bills = Variable<[Bill]>([])
    let formattedBills = Variable<[Bill]>([])
    
    let contentOffset = Variable<CGFloat>(0)
    
    // MARK - Initialization -
    init(with client: CongressService) {
        self.client = client
        bind()
    }
    
    func update(with representative: Person) {
        self.bio.value = representative.biography ?? ""
        self.terms.value = representative.terms ?? []
        self.loadStatus.value = .none
        self.representative.value = representative
        fetchTallies()
        fetchBills()
    }
    
    // MARK - Client Requests -
    func fetchTallies() {
        guard let rep = representative.value else { return }
        loadStatus.value = .loading
        client.fetchTallies(personID: rep.id, pageNumber: tallyPageCount)
            .subscribe(
                onNext: { [weak self] tallies in
                    self?.loadStatus.value = .none
                    self?.tallies.value = tallies
                    self?.tallyPageCount += 1
                },
                onError: { [weak self] (error) in
                    self?.loadStatus.value = .error(KratosError.cast(from: error))
            })
            .disposed(by: disposeBag)
    }
    
    func fetchBills() {
        guard let rep = representative.value else { return }
        loadStatus.value = .loading
        client.fetchSponsoredBills(personID: rep.id, pageNumber: sponsoredBillCount)
            .subscribe(
                onNext: { [weak self] bills in
                    self?.loadStatus.value = .none
                    self?.bills.value = bills
                    self?.sponsoredBillCount += 1
                },
                onError: { [weak self] (error) in
                    self?.loadStatus.value = .error(KratosError.cast(from: error))
            })
            .disposed(by: disposeBag)
    }
}

// MARK - Binds -
extension RepInfoViewModel: RxBinder {
    func bind() {
        fetchAction
            .asObservable()
            .withLatestFrom(state.asObservable())
            .subscribe(onNext: { [weak self] state in
                switch state {
                case .bills: self?.fetchBills()
                case .votes: self?.fetchTallies()
                default: break
                }
            })
            .disposed(by: disposeBag)
        
        tallies
            .asObservable()
            .scan([]) { $0 + $1 }
            .map { tallies  -> [[[LightTally]]] in
                let arrays = tallies.grouped(groupBy: { $0.date.startOf(component: .day) }, sortGroupsBy: {$0.date.startOf(component: .day) > $1.date.startOf(component: .day)})
                return arrays.map { $0.grouped(groupBy: { $0.billId ?? 0 }) }
            }
            .bind(to: formattedTallies)
            .disposed(by: disposeBag)
        
        bills
            .asObservable()
            .scan([]) { $0 + $1 }
            .bind(to: formattedBills)
            .disposed(by: disposeBag)
    }
}
