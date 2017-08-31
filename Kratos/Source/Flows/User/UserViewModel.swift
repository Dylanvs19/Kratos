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
    let loadStatus = Variable<LoadStatus>(.none)
    
    let trackedSubjects = Variable<[Subject]>([])
    let selectedSubjects = Variable<[Subject]>([])
    
    let trackedBillsSelected = Variable<Bool>(true)
    
    let trackedBills = Variable<[Bill]>([])
    let subjectBills = Variable<[Bill]>([])
    
    let presentedBills = Variable<[Bill]>([])
    
    var trackedBillsPageNumber = 1
    var billsForSubjectsPageNumber = 1
    
    // MARK: - Initializer -
    init(client: Client) {
        self.client = client
        bind()
        fetchTrackedSubjects()
    }
    
    func fetchTrackedBills() {
        loadStatus.value = .loading
        client.fetchTrackedBills(for: trackedBillsPageNumber)
            .subscribe(
                onNext: { [weak self] bills in
                    self?.loadStatus.value = .none
                    self?.trackedBills.value = bills
                    self?.trackedBillsPageNumber += 1
                },
                onError: { [weak self] (error) in
                    self?.loadStatus.value = .error(error: KratosError.cast(from: error))
            })
            .disposed(by: disposeBag)
    }
    
    func fetchTrackedSubjects() {
        loadStatus.value = .loading
        client.fetchTrackedSubjects()
            .subscribe(
                onNext: { [weak self] subjects in
                    self?.loadStatus.value = .none
                    let trackedBills = [Subject(name: "Tracked", id: -1),
                                        Subject(name: "Tracked Bills", id: -1),
                                        Subject(name: "s", id: -1),
                                        Subject(name: "Tracked Bills", id: -1),
                                        Subject(name: "New Hampshire LongTooth Salamander", id: -1)]
                    self?.trackedSubjects.value = trackedBills + subjects
                },
                onError: { [weak self] (error) in
                    self?.loadStatus.value = .error(error: KratosError.cast(from: error))
            })
            .disposed(by: disposeBag)
    }
    
    func fetchBillsBySubject() {
        loadStatus.value = .loading
        client.fetchBills(for: trackedSubjects.value, tracked: true, pageNumber: billsForSubjectsPageNumber)
            .subscribe(
                onNext: { [weak self] bills in
                    self?.loadStatus.value = .none
                    self?.trackedBills.value = bills
                    self?.trackedBillsPageNumber += 1
                },
                onError: { [weak self] (error) in
                    self?.loadStatus.value = .error(error: KratosError.cast(from: error))
            })
            .disposed(by: disposeBag)
    }
}

extension UserViewModel: RxBinder {
    
    func bind() {

        
    }
}
