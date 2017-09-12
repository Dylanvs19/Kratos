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
    
    let representative = Variable<Person?>(nil)
    
    let title = Variable<String>("")
    let repTypeState = Variable<String>("")
    let state = Variable<State?>(nil)
    let party = Variable<String>("")
    let url = Variable<URL?>(nil)
    
    //Representative ContactView Variables
    let contactMethods = Variable<[RepContactView.ContactMethod]>([])
    
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
    
    func reloadTitle() {
        title.value = title.value
    }
}

extension RepresentativeViewModel: RxBinder {
    func bind() {
        bindHeaderVariables()
        bindContactVariables()
        bindRepInfoView()
    }

    func bindHeaderVariables() {
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
    }
    
    func bindContactVariables() {
        representative
            .asObservable()
            .map {
                var contactMethods: [RepContactView.ContactMethod] = []
                if let phone = $0?.terms?.first?.phone {
                    contactMethods.append(.phone(phone))
                }
                if let url = $0?.terms?.first?.website {
                    contactMethods.append(.website(url))
                }
                if let handle = $0?.twitter {
                    contactMethods.append(.twitter(handle))
                }
                if let address = $0?.terms?.first?.officeAddress {
                    contactMethods.append(.office(address))
                }
                return contactMethods
            }
            .bind(to: contactMethods)
            .disposed(by: disposeBag)
    }
}

