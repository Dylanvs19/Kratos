//
//  AccountDetailsViewModel.swift
//  Kratos
//
//  Created by Dylan Straughan on 5/20/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import RxSwift

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
    let user = PublishSubject<User>()
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
    let nextViewController = PublishSubject<UIViewController>()
    
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
        return last.asObservable()
            .map { InputValidation.address(address: $0).isValid }
    }
    var dobValid : Observable<Bool> {
        return last.asObservable()
            .map { InputValidation.address(address: $0).isValid }
    }
    var streetValid : Observable<Bool> {
        return last.asObservable()
            .map { InputValidation.address(address: $0).isValid }
    }
    var cityValid : Observable<Bool> {
        return last.asObservable()
            .map { InputValidation.city(city: $0).isValid }
    }
    var stateValid : Observable<Bool> {
        return last.asObservable()
            .map { InputValidation.state(state: $0).isValid }
    }
    var zipValid : Observable<Bool> {
        return last.asObservable()
            .map { InputValidation.zipcode(zipcode: $0).isValid }
    }
    
    //MARK: Methods
    init(client: Client, viewState: ViewState) {
        self.client = client
        self.viewState.value = viewState
        self.bind()
        
    }
    
    func fetchUser() -> Observable<User> {
        loadStatus.value = .loading
        return client.fetchUser()
            .do(onNext: { [unowned self] user in
                self.loadStatus.value = .none
            }, onError: { [unowned self] (error) in
                let error = error as? KratosError ?? KratosError.unknown
                self.loadStatus.value = .error(error: error)
            })
    }
    
    func buildUser() -> User {
        
        var user = User()
        user.email = email.value
        user.firstName = first.value
        user.lastName = last.value
        user.party = Party.value(for: party.value)
        user.dob = dob.value.stringToDate()
        
        var address = Address()
        address.street = street.value
        address.city = city.value
        address.state = state.value
        address.zipCode = Int(zip.value)
        
        user.address = address
        
        return user
    }
    
    func register() {
        loadStatus.value = .loading
        client.register(user: buildUser())
            .map{ $0.0 }
            .subscribe(onNext: { [unowned self] in
                self.loadStatus.value = .none
                if KeychainManager.create($0) {
                    let vc = ConfirmationViewController(client: self.client)
                    self.nextViewController.onNext(vc)
                } else {
                    fatalError("Could not save token for keychain")
                }
                }, onError: { (error) in
                    let error = error as? KratosError ?? KratosError.unknown
                    self.loadStatus.value = .error(error: error)
            })
            .disposed(by: disposeBag)
    }
    
    func edit() {
        viewState.value = .editAccount
    }
    
    func save() {
        loadStatus.value = .loading
        client.updateUser(user: buildUser())
            .do(onNext: { [unowned self] (user) in
                self.loadStatus.value = .none
            }, onError: { (error) in
                let error = error as? KratosError ?? KratosError.unknown
                self.loadStatus.value = .error(error: error)
            }, onCompleted: { 
                self.loadStatus.value = .none
            })
            .bind(to: user)
            .disposed(by: disposeBag)
    }
    
    func cancel() {
        viewState.value = .viewAccount
    }
    
    func done() {
        //dismissVC
    }
    
    func bind() {
        
        fetchUser().asObservable()
            .bind(to: user)
            .disposed(by: disposeBag)
        
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
}
