//
//  SubjectSelectionViewModel.swift
//  Kratos
//
//  Created by Dylan Straughan on 9/6/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


class SubjectSelectionViewModel {
    
    // MARK: - Variables -
    let client: Client
    let disposeBag = DisposeBag()
    let loadStatus = Variable<LoadStatus>(.none)

    let subjects = Variable<[Subject]>([])
    let selectedSubjects = Variable<[Subject]>([])
    
    // MARK: - Initializer -
    init(client: Client) {
        self.client = client
        bind()
        fetchSubjects()
        fetchTrackedSubjects()
    }
    
    func fetchSubjects() {
        loadStatus.value = .loading
        client.fetchAllSubjects()
            .subscribe(
                onNext: { [weak self] subjects in
                    self?.loadStatus.value = .none
                    self?.subjects.value = subjects
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
                    self?.loadStatus.value = .none
                    self?.selectedSubjects.value = subjects
                },
                onError: { [weak self] (error) in
                    self?.loadStatus.value = .error(KratosError.cast(from: error))
            })
            .disposed(by: disposeBag)
    }
}

extension SubjectSelectionViewModel: RxBinder {
    func bind() {
        
    }
}
