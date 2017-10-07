//
//  RepresentativeViewModel.swift
//  Kratos
//
//  Created by Dylan Straughan on 6/14/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


class RepresentativeViewModel {
    
    let client: Client
    let disposeBag = DisposeBag()
    let loadStatus = Variable<LoadStatus>(.none)
    
    let lightRep = Variable<LightPerson?>(nil)
    let representative = Variable<Person?>(nil)
    
    let title = Variable<String>("")
    let repTypeState = Variable<String>("")
    let state = Variable<State?>(nil)
    let party = Variable<String>("")
    let url = Variable<URL?>(nil)
    
    //Representative ContactView Variables
    let contactMethods = Variable<[RepContactView.Contact]>([])
    
    //RepInfo Variables
    let contentOffset = Variable<CGFloat>(0)
    //Bio Variables
    var bio = Variable<String>("")
    var terms = Variable<[Term]>([])
    
    init(client: Client, representative: Person) {
        self.client = client
        self.representative.value = representative
        bind()
    }
    
    init(client: Client, representative: LightPerson) {
        self.client = client
        self.lightRep.value = representative
        loadStatus.value = .loading
        bind()
    }
    
    func fetchRepresentative() {
        guard let lightRep = lightRep.value else { return }
        client.fetchPerson(personID: lightRep.id)
            .subscribe(
                onNext: { [weak self] person in
                    self?.loadStatus.value = .none
                    self?.representative.value = person
                }, onError: { [weak self] error in
                    self?.loadStatus.value = .error(KratosError.cast(from: error))
                }
            )
            .disposed(by: disposeBag)
    }
    
    func reloadTitle() {
        title.value = title.value
    }
    
    func logContactEvent(contact: RepContactView.Contact, personId: Int) {
        client.logContact(contact: contact, personId: personId)
    }
}

extension RepresentativeViewModel: RxBinder {
    func bind() {
        bindHeaderVariables()
        bindContactVariables()
    }

    func bindHeaderVariables() {
        lightRep
            .asObservable()
            .filterNil()
            .subscribe(
                onNext: { [weak self] _ in
                    self?.fetchRepresentative()
                }
            )
            .disposed(by: disposeBag)
        representative
            .asObservable()
            .filterNil()
            .map { $0.fullName }
            .bind(to: title)
            .disposed(by: disposeBag)
        representative
            .asObservable()
            .filterNil()
            .map { "\($0.currentChamber.representativeType.short()). \($0.currentState.fullName)" }
            .bind(to: repTypeState)
            .disposed(by: disposeBag)
        representative
            .asObservable()
            .filterNil()
            .map { $0.currentParty?.long }
            .filterNil()
            .bind(to: party)
            .disposed(by: disposeBag)
        representative
            .asObservable()
            .filterNil()
            .map { $0.currentState }
            .bind(to: state)
            .disposed(by: disposeBag)
        representative
            .asObservable()
            .filterNil()
            .map { $0.biography }
            .filterNil()
            .bind(to: bio)
            .disposed(by: disposeBag)
        representative
            .asObservable()
            .filterNil()
            .map { $0.terms }
            .filterNil()
            .bind(to: terms)
            .disposed(by: disposeBag)
        representative
            .asObservable()
            .filterNil()
            .map { $0.imageURL }
            .filterNil()
            .map { URL(string: $0) }
            .bind(to: url)
            .disposed(by: disposeBag)
        representative
            .asObservable()
            .filterNil()
            .subscribe(
                onNext: { [weak self] rep in
                    self?.client.logView(type: .repViewed(id: rep.id))
                }
            )
            .disposed(by: disposeBag)
        
    }
    
    func bindContactVariables() {
        representative
            .asObservable()
            .map {
                var contactMethods: [RepContactView.Contact] = []
                if let phone = $0?.terms?.first?.phone {
                    contactMethods.append(RepContactView.Contact(method: .phone, value: phone))
                }
                if let url = $0?.terms?.first?.website {
                    contactMethods.append(RepContactView.Contact(method: .website, value: url))
                }
                if let handle = $0?.twitter {
                    contactMethods.append(RepContactView.Contact(method: .twitter, value: handle))
                }
                if let address = $0?.terms?.first?.officeAddress {
                    contactMethods.append(RepContactView.Contact(method: .office, value: address))
                }
                return contactMethods
            }
            .bind(to: contactMethods)
            .disposed(by: disposeBag)
    }
}

