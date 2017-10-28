//
//  UserBillsViewModel.swift
//  Kratos
//
//  Created by Dylan Straughan on 8/1/17.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class UserViewModel {
    
    enum EmptyState {
        case noTrackedSubjectsOrBills
        case noSelectedSubjects
        case noBilsForSubject
        case notEmpty
        
        var title: String {
            switch self {
            case .noTrackedSubjectsOrBills: return localize(.userBillsNoTrackedSubjectsOrBillsEmptyStateMessage)
            case .noSelectedSubjects: return localize(.userBillsNoSubjectSelectedEmptyStateMessage)
            case .noBilsForSubject: return localize(.userBillsSubjectEmptyStateMessage)
            case .notEmpty: return ""
            }
        }
    }
    
    // MARK: - Variables -
    let client: Client
    fileprivate let disposeBag = DisposeBag()
    fileprivate var billsDisposeBag: DisposeBag? = DisposeBag()
    let loadStatus = Variable<LoadStatus>(.none)
    let emptyState = Variable<EmptyState>(.notEmpty)
    
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
        trackedSubjects.value = []
        loadStatus.value = .loading
        client.fetchTrackedSubjects(ignoreCache: true)
            .subscribe(
                onNext: { [weak self] subjects in
                    guard let `self` = self else { fatalError("self deallocated before it was accessed") }
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
    
    func reloadData() {
        clearSelectedSubjects()
        resetBills()
    }
}

extension UserViewModel: RxBinder {
    
    func bind() {
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
            .subscribe(
                onNext: { [weak self] subjects in
                    guard let `self` = self else { fatalError("self deallocated before it was accessed")}
                    self.pageNumber = 1
                    self.trackedBillsSelected.value = subjects.contains(self.trackedBillsSubject)
                    let filtered = subjects.filter { $0 != self.trackedBillsSubject }
                    self.resetBills()
                    self.fetchBills(for: filtered)
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
        Observable.combineLatest(selectedSubjects.asObservable(), trackedSubjects.asObservable(), presentedBills.asObservable()) { (selected, tracked, presented) -> EmptyState in
            guard presented.isEmpty else { return .notEmpty }
            guard tracked.count > 1 else { return .noTrackedSubjectsOrBills }
            guard selected.count > 0 else { return .noSelectedSubjects }
            return .noBilsForSubject
            }
            .bind(to: emptyState)
            .disposed(by: disposeBag)
    }
}
