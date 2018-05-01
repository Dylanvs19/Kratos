//
//  AccountDetailsViewModel.swift
//  Kratos
//
//  Created by Dylan Straughan on 5/20/17.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Firebase
import FirebaseMessaging

class AccountDetailsViewModel {
    
    let client: Client
    let loadStatus = Variable<LoadStatus>(.none)
    let registerLoadStatus = Variable<LoadStatus>(.none)
    let disposeBag = DisposeBag()
    
    let user = Variable<User?>(nil)
    let state = Variable<AccountDetailsController.State>(.edit)
    
    let email = Variable<String>("")
    let password = Variable<String>("")
    let first = Variable<String>("")
    let last = Variable<String>("")
    let dob = Variable<String>("")
    let party = Variable<String>("")
    let street = Variable<String>("")
    let city = Variable<String>("")
    let userState = Variable<String>("")
    let zip = Variable<String>("")
    let oldPassword = Variable<String>("")
    let newPassword = Variable<String>("")
    
    let firstValid = BehaviorSubject<Bool>(value: false)
    let lastValid = BehaviorSubject<Bool>(value: false)
    let partyValid = BehaviorSubject<Bool>(value: false)
    let dobValid = BehaviorSubject<Bool>(value: false)
    let streetValid = BehaviorSubject<Bool>(value: false)
    let cityValid = BehaviorSubject<Bool>(value: false)
    let stateValid = BehaviorSubject<Bool>(value: false)
    let zipValid = BehaviorSubject<Bool>(value: false)
    
    var formValid = BehaviorSubject<Bool>(value: false)
    
    //MARK: Methods
    init(with client: Client, state: AccountDetailsController.State, credentials: (email: String, password: String)) {
        self.client = client
        self.state.value = state
        self.email.value = credentials.email
        self.password.value = credentials.password
        bind()
    }
    
    func fetchUser() {
        loadStatus.value = .loading
    }
    
    func register() {
        registerLoadStatus.value = .loading
        client.register(user: buildRegistrationUser(), fcmToken: InstanceID.instanceID().token())
            .subscribe(onNext: { [weak self] success in
                self?.registerLoadStatus.value = .none
            }, onError: { [weak self] error in
                self?.loadStatus.value = .error(KratosError.cast(from: error))
            })
            .disposed(by: disposeBag)
    }
    
    func save() {
        client.updateUser(user: updateUser(), fcmToken: InstanceID.instanceID().token())
    }
    
    func buildRegistrationUser() -> User {
        return  User(id: 0,
                     email: email.value,
                     firstName: first.value,
                     lastName: last.value,
                     district: District(state: .puertoRico, district: 0),
                     address: Address(street: street.value,
                                      city: city.value,
                                      state: userState.value,
                                      zipCode: Int(zip.value) ?? 0),
                     dob: dob.value.date ?? Date(),
                     party: Party.value(for: party.value),
                     password: password.value)
        
    }
    
    func updateUser() -> User {
        guard let user = user.value else { fatalError("No user value to update") }
        return user.update(email: email.value,
                    firstName: first.value,
                    lastName: last.value, 
                    district: nil,
                    address: Address(street: street.value,
                                     city: city.value,
                                     state: userState.value,
                                     zipCode: Int(zip.value) ?? 0),
                    dob: dob.value.date ?? Date(),
                    party: Party.value(for: party.value),
                    password: password.value)
    }
}

extension AccountDetailsViewModel: RxBinder {

    func bind() {
        setupViewStateBindings()
        setupValidationBindings()
        setupUserBindings()
    }
    
    func setupViewStateBindings() {
        state
            .asObservable()
            .filter { $0 == .edit }
            .subscribe(onNext: { [weak self] _ in
                self?.fetchUser()
            })
            .disposed(by: disposeBag)
    }
    
    func setupValidationBindings() {
        Observable.combineLatest(firstValid.asObservable(),
                                 lastValid.asObservable(),
                                 partyValid.asObservable(),
                                 dobValid.asObservable(),
                                 streetValid.asObservable(),
                                 stateValid.asObservable(),
                                 cityValid.asObservable(),
                                 zipValid.asObservable()) {
                return $0 && $1 && $2 && $3 && $4 && $5 && $6 && $7
            }
            .bind(to: formValid)
            .disposed(by: disposeBag)
    }
    
    func setupUserBindings() {
        client.user
            .asObservable()
            .bind(to: user)
            .disposed(by: disposeBag)
        
        let nonNilUser = user.asObservable().filterNil()
        
        nonNilUser
            .map { $0.firstName }
            .bind(to: first)
            .disposed(by: disposeBag)
        
        nonNilUser
            .map { $0.lastName }
            .bind(to: last)
            .disposed(by: disposeBag)
        
        nonNilUser
            .map { $0.party?.long }
            .filterNil()
            .bind(to: party)
            .disposed(by: disposeBag)
        
        nonNilUser
            .map { $0.dob }
            .map { DateFormatter.presentation.string(from: $0) }
            .bind(to: dob)
            .disposed(by: disposeBag)
        
        nonNilUser
            .map { $0.address.street }
            .bind(to: street)
            .disposed(by: disposeBag)
        
        nonNilUser
            .map { $0.address.city }
            .bind(to: city)
            .disposed(by: disposeBag)
        
        nonNilUser
            .map { $0.address.state }
            .bind(to: userState)
            .disposed(by: disposeBag)
        
        nonNilUser
            .map { $0.address.zipCode }
            .map { String($0) }
            .bind(to: zip)
            .disposed(by: disposeBag)
    }
}
