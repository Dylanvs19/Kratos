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
    fileprivate let disposeBag = DisposeBag()
    fileprivate var billsDisposeBag: DisposeBag? = DisposeBag()
    let loadStatus = Variable<LoadStatus>(.none)
    
    let trackedSubjects = Variable<[Subject]>([])
    let selectedSubjects = Variable<[Subject]>([])
    
    let trackedBillsSelected = Variable<Bool>(true)
    let clearable = Variable<Bool>(true)
    
    fileprivate let bills = Variable<[Bill]>([])
    let presentedBills = Variable<[Bill]>([])
    
    let fetchAction = PublishSubject<Void>()

    fileprivate var pageNumber = 1
    
    let trackedBillsSubject = Subject(name: "Tracked Bills", id: -1)
    
    // MARK: - Initializer -
    init(client: Client) {
        self.client = client
        bind()
    }
    
    func fetchBills(for subjects: [Subject]) {
//        guard let disposeBag = disposeBag else { return }
        if pageNumber == 1 {
            loadStatus.value = .loading
        }
        client.fetchBills(for: subjects, tracked: trackedBillsSelected.value, pageNumber: pageNumber)
            .subscribe(
                onNext: { [weak self] bills in
                    if self?.pageNumber == 1 {
                        self?.loadStatus.value = .none
                    }
                    self?.bills.value = bills
                    self?.pageNumber += 1
                },
                onError: { [weak self] (error) in
                    self?.loadStatus.value = .error(KratosError.cast(from: error))
            })
            .disposed(by: disposeBag)
    }
    
    func fetchTrackedSubjects() {
//        guard let disposeBag = disposeBag else { return }
        trackedSubjects.value = []
        loadStatus.value = .loading
        client.fetchTrackedSubjects(ignoreCache: true)
            .subscribe(
                onNext: { [weak self] subjects in
                    guard let `self` = self else { fatalError("self deallocated before it was accessed") }
                    print(subjects)
                    self.trackedSubjects.value = [self.trackedBillsSubject] + subjects
                },
                onError: { [weak self] (error) in
                    self?.loadStatus.value = .error(KratosError.cast(from: error))
            })
            .disposed(by: disposeBag)
    }
    func clearSelectedSubjects() {
        selectedSubjects.value = []
    }
    
    func resetBills() {
        billsDisposeBag = nil
        billsDisposeBag = DisposeBag()
        guard let billsDisposeBag = billsDisposeBag else { return }
        presentedBills.value = []
        bills.value = []
        bills
            .asObservable()
            .scan([]) { $0 + $1 }
            .bind(to: presentedBills)
            .addDisposableTo(billsDisposeBag)
    }
    
//    func totalReset() {
//        resetBills()
//        disposeBag = nil
//        bind()
//        fetchTrackedSubjects()
//    }
//
    func reloadData() {
        clearSelectedSubjects()
        resetBills()
    }
}

extension UserViewModel: RxBinder {
    
    func bind() {
//        self.disposeBag = DisposeBag()
//        guard let disposeBag = disposeBag else { return }
        trackedSubjects
            .asObservable()
            .bind(to: selectedSubjects)
            .disposed(by: disposeBag)
        selectedSubjects
            .asObservable()
            .map { $0.contains(where: { $0 == self.trackedBillsSubject }) }
            .bind(to: trackedBillsSelected)
            .disposed(by: disposeBag)
        selectedSubjects
            .asObservable()
            .map { $0.filter { $0 != self.trackedBillsSubject } }
            .subscribe(
                onNext: { [weak self] subjects in
                    self?.pageNumber = 1
                    self?.resetBills()
                    self?.fetchBills(for: subjects)
                }
            )
            .disposed(by: disposeBag)
        selectedSubjects
            .asObservable()
            .filter { $0.isEmpty }
            .withLatestFrom(trackedSubjects.asObservable())
            .map { $0.filter { $0 != self.trackedBillsSubject } }
            .subscribe(
                onNext: { [weak self] subjects in
                    self?.trackedBillsSelected.value = true
                    self?.pageNumber = 1
                    self?.resetBills()
                    self?.fetchBills(for: subjects)
                }
            )
            .disposed(by: disposeBag)
        selectedSubjects
            .asObservable()
            .map { $0.count != 0 }
            .bind(to: clearable)
            .disposed(by: disposeBag)
        fetchAction.asObservable()
            .withLatestFrom(selectedSubjects.asObservable())
            .map { $0.filter { $0 != self.trackedBillsSubject } }
            .subscribe(
                onNext: { [weak self] subjects in
                    self?.fetchBills(for: subjects)
                }
            )
            .disposed(by: disposeBag)
    }
}
