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
import RxDataSources

class SubjectSelectionViewModel {
    
    // MARK: - Variables -
    let client: Client
    let disposeBag = DisposeBag()
    let loadStatus = Variable<LoadStatus>(.none)
    let updateLoadStatus = Variable<LoadStatus>(.none)
    let query = Variable<String>("")

    fileprivate let subjects = Variable<[Subject]?>(nil)
    let presentedSubjects = Variable<[SectionModel<String, Subject>]>([])
    
    fileprivate let initialSelectedSubjects = Variable<[Subject]>([])
    fileprivate let currentSelectedSubjects = Variable<[Subject]>([])
    
    fileprivate let addedSubjects = Variable<[Subject]>([])
    fileprivate let removedSubjects = Variable<[Subject]>([])
    
    let selectedSubject = Variable<Subject?>(nil)
    let enableUpdate = Variable<Bool>(false)
    
    // MARK: - Initializer -
    init(client: Client) {
        self.client = client
        bind()
        fetchSubjects()
        fetchTrackedSubjects()
    }
    
    // MARK: - Client Requests -
    func updateSubjects() {
        updateLoadStatus.value = .loading
        let added = addedSubjects.value.map { self.add(subject: $0) }
        let removed = removedSubjects.value.map { self.remove(subject: $0) }
        Observable.combineLatest(added + removed)
            .subscribe(
                onNext: { [weak self] _ in
                    self?.updateLoadStatus.value = .none
                },
                onError: { [weak self] error in
                    self?.updateLoadStatus.value = .error(KratosError.cast(from: error))
                }
            )
            .disposed(by: disposeBag)
    }
    fileprivate func fetchSubjects() {
        loadStatus.value = .loading
        client.fetchAllSubjects(onlyActive: true)
            .subscribe(
                onNext: { [weak self] subjects in
                    self?.loadStatus.value = .none
                    self?.subjects.value = subjects
                },
                onError: { [weak self] (error) in
                    self?.loadStatus.value = .error(KratosError.cast(from: error))
                }
            )
            .disposed(by: disposeBag)
    }
    fileprivate func fetchTrackedSubjects() {
        loadStatus.value = .loading
        client.fetchTrackedSubjects()
            .subscribe(
                onNext: { [weak self] subjects in
                    self?.loadStatus.value = .none
                    self?.initialSelectedSubjects.value = subjects
                    self?.currentSelectedSubjects.value = subjects
                },
                onError: { [weak self] (error) in
                    self?.loadStatus.value = .error(KratosError.cast(from: error))
                }
            )
            .disposed(by: disposeBag)
    }
    
    fileprivate func add(subject: Subject) -> Observable<Void> {
        return client.followSubject(subjectID: subject.id)
    }
    
    fileprivate func remove(subject: Subject) -> Observable<Void> {
        return client.unfollowSubject(subjectID: subject.id)
    }
    
    fileprivate func follow(subjects: [Subject]) {
        loadStatus.value = .loading
        Observable.combineLatest(subjects.map { self.add(subject: $0) })
            .subscribe(
                onNext: { [weak self] _ in
                    self?.loadStatus.value = .none
                },
                onError: { [weak self] error in
                    self?.loadStatus.value = .error(KratosError.cast(from: error))
                }
            )
            .disposed(by: disposeBag)
    }
    
    fileprivate func unfollow(subjects: [Subject]) {
        loadStatus.value = .loading
        Observable.combineLatest(subjects.map { self.add(subject: $0) })
            .subscribe(
                onNext: { [weak self] _ in
                    self?.loadStatus.value = .none
                },
                onError: { [weak self] error in
                    self?.loadStatus.value = .error(KratosError.cast(from: error))
                }
            )
            .disposed(by: disposeBag)
    }
}

// MARK: - RxBinder -
extension SubjectSelectionViewModel: RxBinder {
    func bind() {
        let initialData = Observable.combineLatest(subjects.asObservable().filterNil(), currentSelectedSubjects.asObservable().filter { !$0.isEmpty } )
        let data = Observable.combineLatest(subjects.asObservable().filterNil(), query.asObservable())
        
       initialData
            .take(1)
            .map { subjects, current in
                let filteredAllData = subjects.filter { !current.contains($0) }
                var allData = filteredAllData.grouped(groupBy: { $0.name.firstLetter }, sortGroupsBy: { $0.name.firstLetter < $1.name.firstLetter })
                let sortedCurrent = current.sorted { $0.0.name < $0.1.name }
                var retVal = allData.map { SectionModel<String, Subject>(model: ($0.first?.name.firstLetter ?? "" ), items: $0)}
                if !sortedCurrent.isEmpty {
                    retVal.insert(SectionModel<String, Subject>(model: "☆", items: sortedCurrent), at: 0)
                }
                return retVal
            }
            .bind(to: presentedSubjects)
            .disposed(by: disposeBag)
        
        data
            .skip(1)
            .map { subjects, query in
                let current = self.currentSelectedSubjects.value
                guard query != "" && query != " " else {
                    let filteredAllData = subjects.filter { !current.contains($0) }
                    var allData = filteredAllData.grouped(groupBy: { $0.name.firstLetter }, sortGroupsBy: { $0.name.firstLetter < $1.name.firstLetter })
                    let sortedCurrent = current.sorted { $0.0.name < $0.1.name }
                    var retVal = allData.map { SectionModel<String, Subject>(model: ($0.first?.name.firstLetter ?? "" ), items: $0)}
                    if !sortedCurrent.isEmpty {
                        retVal.insert(SectionModel<String, Subject>(model: "☆", items: sortedCurrent), at: 0)
                    }
                    return retVal
                }
                let filteredCurrent = self.currentSelectedSubjects.value.filter { $0.name.contains(query) }.sorted { $0.0.name < $0.1.name }
                let filteredSubjects = subjects.filter { $0.name.contains(query) }.filter { !filteredCurrent.contains($0) }
                var returnData = filteredSubjects.grouped(groupBy: { $0.name.firstLetter }, sortGroupsBy: { $0.name.firstLetter < $1.name.firstLetter })
                var retVal = returnData.map { SectionModel<String, Subject>(model: ($0.first?.name.firstLetter ?? "" ), items: $0)}
                if !filteredCurrent.isEmpty {
                    retVal.insert(SectionModel<String, Subject>(model: "☆", items: filteredSubjects), at: 0)
                }
                return retVal
            }
            .bind(to: presentedSubjects)
            .disposed(by: disposeBag)
        
        selectedSubject
            .asObservable()
            .filterNil()
            .map { selectedSubject in
                if self.currentSelectedSubjects.value.contains(selectedSubject) {
                    return self.currentSelectedSubjects.value.filter { $0 != selectedSubject }
                } else {
                    return self.currentSelectedSubjects.value + [selectedSubject]
                }
            }
            .bind(to: currentSelectedSubjects)
            .disposed(by: disposeBag)
        currentSelectedSubjects
            .asObservable()
            .withLatestFrom(initialSelectedSubjects.asObservable()) { (current, initial) -> [Subject] in
                return initial.filter { !current.contains($0) }
            }
            .bind(to: removedSubjects)
            .disposed(by: disposeBag)
        currentSelectedSubjects
            .asObservable()
            .withLatestFrom(initialSelectedSubjects.asObservable()) { (current, initial) -> [Subject] in
                return current.filter { !initial.contains($0) }
            }
            .bind(to: addedSubjects)
            .disposed(by: disposeBag)
        Observable.combineLatest(addedSubjects.asObservable(), removedSubjects.asObservable()) { (added, removed) -> Bool in
                return !added.isEmpty || !removed.isEmpty
            }
            .bind(to: enableUpdate)
            .disposed(by: disposeBag)
    }
}
