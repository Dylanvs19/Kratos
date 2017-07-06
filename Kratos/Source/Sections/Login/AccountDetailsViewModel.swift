//
//  AccountDetailsViewModel.swift
//  Kratos
//
//  Created by Dylan Straughan on 5/20/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class AccountDetailsViewModel {
    
    enum ViewState {
        case registration
        case editAccount
        case viewAccount
        
        var saveEditRegisterButtonTitle: String {
            switch self {
            case .registration:
                return "R E G I S T E R"
            case .editAccount:
                return "S A V E"
            case .viewAccount:
                return "E D I T"
            }
        }
        
        var cancelDoneButtonTitle: String {
            switch self {
            case .registration:
                return ""
            case .editAccount:
                return "C A N C E L"
            case .viewAccount:
                return "D O N E"
            }
        }
    }
    
    let client: Client
    let user = Variable<User?>(nil)
    let viewState = Variable<ViewState>(.viewAccount)
    let loadStatus = Variable<LoadStatus>(.none)
    let disposeBag = DisposeBag()
    
    let email = Variable<String>("")
    let password = Variable<String>("")
    let first = Variable<String>("")
    let last = Variable<String>("")
    let dob = Variable<String>("")
    let party = Variable<String>("")
    let street = Variable<String>("")
    let city = Variable<String>("")
    let state = Variable<String>("")
    let zip = Variable<String>("")
    let oldPassword = Variable<String>("")
    let newPassword = Variable<String>("")
    
    let saveEditRegisterButtonTap = PublishSubject<Void>()
    let cancelDoneButtonTap = PublishSubject<Void>()
    
    var formValid : Observable<Bool> {
        return Observable.combineLatest(firstValid,
                                        lastValid,
                                        partyValid,
                                        dobValid,
                                        streetValid,
                                        stateValid,
                                        cityValid,
                                        zipValid) { (first, last, party, dob, street, city, state, zip) in
            return first && last && party && dob && street && city && state && zip
        }
    }
    
    var firstValid : Observable<Bool> {
        return first.asObservable()
            .map { InputValidation.address(address:$0).isValid }
    }
    var lastValid : Observable<Bool> {
        return last.asObservable()
            .map { InputValidation.address(address: $0).isValid }
    }
    var partyValid : Observable<Bool> {
        return party.asObservable()
            .map { InputValidation.address(address: $0).isValid }
    }
    var dobValid : Observable<Bool> {
        return dob.asObservable()
            .map { InputValidation.address(address: $0).isValid }
    }
    var streetValid : Observable<Bool> {
        return street.asObservable()
            .map { InputValidation.address(address: $0).isValid }
    }
    var cityValid : Observable<Bool> {
        return city.asObservable()
            .map { InputValidation.city(city: $0).isValid }
    }
    var stateValid : Observable<Bool> {
        return state.asObservable()
            .map { InputValidation.state(state: $0).isValid }
    }
    var zipValid : Observable<Bool> {
        return zip.asObservable()
            .map { InputValidation.zipcode(zipcode: $0).isValid }
    }
    
    var push = Variable<Bool>(false)
    
    //MARK: Methods
    init(client: Client, viewState: ViewState) {
        self.client = client
        self.viewState.value = viewState
        bind()
    }
    
    func fetchUser() {
        loadStatus.value = .loading
        client.fetchUser()
            .catchError({ (error) in
                let error = error as? KratosError ?? KratosError.unknown
                self.loadStatus.value = .error(error: error)
                throw error
            })
            .subscribe(onNext: { [unowned self] user in
                self.loadStatus.value = .none
                self.user.value = user
            })
            .disposed(by: disposeBag)
    }
    
    func register() {
        loadStatus.value = .loading
        client.register(user: buildRegistrationUser())
            .catchError({ (error) in
                let error = error as? KratosError ?? KratosError.unknown
                self.loadStatus.value = .error(error: error)
                throw error
            })
            .do(onNext: { [unowned self] _ in
                self.loadStatus.value = .none
            })
            .bind(to: push)
            .disposed(by: disposeBag)
    }
    
    func edit() {
        viewState.value = .editAccount
    }
    
    func save() {
        loadStatus.value = .loading
        client.updateUser(user: updateUser())
            .subscribe(onNext: { [unowned self] (user) in
                self.loadStatus.value = .none
                self.user.value = user
            }, onError: { (error) in
                let error = error as? KratosError ?? KratosError.unknown
                self.loadStatus.value = .error(error: error)
            })
            .disposed(by: disposeBag)
    }
    
    func cancel() {
        viewState.value = .viewAccount
    }
    
    func done() {
        //dismissVC
    }
    
    func buildRegistrationUser() -> User {
        
        return  User(id: 0,
                     email: email.value,
                     firstName: first.value,
                     lastName: last.value,
                     district: 0,
                     address: Address(street: state.value,
                                      city: city.value,
                                      state: state.value,
                                      zipCode: Int(zip.value) ?? 0),
                     dob: dob.value.stringToDate() ?? Date(),
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
                                     state: state.value,
                                     zipCode: Int(zip.value) ?? 0),
                    dob: dob.value.stringToDate() ?? Date(),
                    party: Party.value(for: party.value),
                    password: password.value)
    }
}

extension AccountDetailsViewModel: RxBinder {

    func bind() {
        setupViewStateBindings()
        setupInteractionBindings()
        setupUserBindings()
    }
    
    func setupViewStateBindings() {
        viewState.asObservable()
            .filter { $0 == .viewAccount }
            .subscribe(onNext: { [weak self] _ in
                self?.fetchUser()
            })
            .disposed(by: disposeBag)
    }
    
    func setupInteractionBindings() {
        saveEditRegisterButtonTap.asObservable()
            .map { self.viewState.value }
            .throttle(2, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] (state) in
                switch state {
                case .registration:
                    self.register()
                case .editAccount:
                    self.save()
                case .viewAccount:
                    self.edit()
                }
            })
            .disposed(by: disposeBag)
        
        cancelDoneButtonTap.asObservable()
            .map { self.viewState.value }
            .subscribe(onNext: { [unowned self] (state) in
                switch state {
                case .registration:
                    break
                case .editAccount:
                    self.cancel()
                case .viewAccount:
                    self.done()
                }
            })
            .disposed(by: disposeBag)
    }
    
    func setupUserBindings() {
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
            .map { DateFormatter.presentationDateFormatter.string(from: $0) }
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
            .bind(to: state)
            .disposed(by: disposeBag)
        
        nonNilUser
            .map { $0.address.zipCode }
            .map { String($0) }
            .bind(to: zip)
            .disposed(by: disposeBag)
        
    }
}
