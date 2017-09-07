//
//  UserBillsViewModel.swift
//  Kratos
//
//  Created by Dylan Straughan on 8/1/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


class UserViewModel {
    
    // MARK: - Variables -
    let client: Client
    let disposeBag = DisposeBag()
    var billsDisposeBag: DisposeBag? = DisposeBag()
    let loadStatus = Variable<LoadStatus>(.none)
    
    let trackedSubjects = Variable<[Subject]>([])
    let selectedSubjects = Variable<[Subject]>([])
    
    let trackedBillsSelected = Variable<Bool>(true)
    
    let bills = Variable<[Bill]>([])
    let presentedBills = Variable<[Bill]>([])
    
    let fetchAction = PublishSubject<Void>()

    var pageNumber = 1
    
    let trackedBillsSubject = Subject(name: "Tracked Bills", id: -1)
    
    // MARK: - Initializer -
    init(client: Client) {
        self.client = client
        bind()
        fetchTrackedSubjects()
    }
    
    func fetchBills(for subjects: [Subject]) {
        loadStatus.value = .loading
        client.fetchBills(for: subjects, tracked: trackedBillsSelected.value, pageNumber: pageNumber)
            .subscribe(
                onNext: { [weak self] bills in
                    self?.loadStatus.value = .none
                    self?.bills.value = bills
                    self?.pageNumber += 1
                },
                onError: { [weak self] (error) in
                    self?.loadStatus.value = .error(KratosError.cast(from: error))
            })
            .disposed(by: disposeBag)
    }
    
    func fetchTrackedSubjects() {
        loadStatus.value = .loading
        client.fetchTrackedSubjects()
            .subscribe(
                onNext: { [weak self] subjects in
                    guard let `self` = self else { fatalError("self deallocated before it was accessed") }
                    self.loadStatus.value = .none
                    self.trackedSubjects.value = [self.trackedBillsSubject] + subjects
                    self.selectedSubjects.value = self.trackedSubjects.value
                },
                onError: { [weak self] (error) in
                    self?.loadStatus.value = .error(KratosError.cast(from: error))
            })
            .disposed(by: disposeBag)
    }
    
    func resetBills() {
        billsDisposeBag = nil
        billsDisposeBag = DisposeBag()
        guard let billsDisposeBag = billsDisposeBag else { return }
        bills.asObservable()
            .do(onNext: { bills in
                for bill in bills {
                    print(bill.topSubject?.name)
                }
            })
            .scan([]) { $0 + $1 }
            .bind(to: presentedBills)
            .disposed(by: billsDisposeBag)
    }
}

extension UserViewModel: RxBinder {
    
    func bind() {
        selectedSubjects
            .asObservable()
            .map { $0.contains(where: { $0 == self.trackedBillsSubject }) }
            .bind(to: trackedBillsSelected)
            .disposed(by: disposeBag)
        
        selectedSubjects
            .asObservable()
            .map { $0.filter { $0 != self.trackedBillsSubject } }
            .subscribe(onNext: { [weak self] subjects in
                self?.pageNumber = 1
                self?.resetBills()
                self?.presentedBills.value = []
                self?.fetchBills(for: subjects)
            })
            .disposed(by: disposeBag)
        
        fetchAction.asObservable()
            .withLatestFrom(selectedSubjects.asObservable())
            .map { $0.filter { $0 != self.trackedBillsSubject } }
            .subscribe(onNext: { [weak self] subjects in
                self?.fetchBills(for: subjects)
            })
            .disposed(by: disposeBag)
        
       resetBills()
    }
}
