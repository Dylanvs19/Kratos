//
//  LoginViewModel.swift
//  Kratos
//
//  Created by Dylan Straughan on 5/10/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import RxSwift
import Action

class LoginViewModel {
    
    enum ViewState: String, RawRepresentable {
        case login = "SIGN UP"
        case registration = "LOGIN"
        case forgotPassword = "FORGOT PASSWORD"
        
        var loginButtonTitle: String {
            switch self {
            case .login:
                return "L O G I N"
            case .registration:
                return "C O N T I N U E"
            case .forgotPassword:
                return "S E N D"
            }
        }
        var signInSignUpButtonTitle: String {
            switch self {
            case .login:
                return "S I G N  U P"
            case .registration:
                return "S I G N  I N"
            case .forgotPassword:
                return "S I G N  U P"
            }
        }
        var forgotPasswordTitle: String {
            return "F O R G O T  P A S S W O R D"
        }
    }
    
    fileprivate var client: Client
    fileprivate let disposeBag = DisposeBag()
    fileprivate var fetchDisposeBag = DisposeBag()
    
    let loadStatus = Variable<LoadStatus>(.none)
    let viewState = Variable<ViewState>(.login)
    let email = Variable<String>("")
    let password = Variable<String>("")
    
    let loginButtonTap = PublishSubject<Void>()
    let forgotPasswordButtonTap = PublishSubject<Void>()
    let signInSignUpButtonTap = PublishSubject<Void>()
    
    let loginSuccessful = PublishSubject<Bool>()
    let forgotPasswordSuccessful = PublishSubject<Bool>()
    let registrationContinueSuccessful = PublishSubject<(email: String, password: String)>()
    
    let user = Variable<User?>(nil)
        
    init(client: Client) {
        self.client = client
        binds()
    }
    
    var formValid : Observable<Bool> {
        return Observable.combineLatest(emailValid, passwordValid) { (email, password) in
            return email && password
        }
    }
    var emailValid : Observable<Bool> {
        return email.asObservable()
            .map { InputValidation.email(email: $0).isValid }
    }
    var passwordValid : Observable<Bool> {
        return password.asObservable()
            .map { InputValidation.password(password: $0).isValid }
    }
    
    fileprivate func postForgotPassword() -> Observable<Bool> {
        loadStatus.value = .loading
        return client.forgotPassword(email: email.value)
            .do(onNext: { [unowned self] (bool) in
                self.loadStatus.value = .none
                //Show Alert saying Email has been sent to Email Account
            }, onError: { [unowned self] error in
                let error = error as? KratosError ?? KratosError.unknown
                self.loadStatus.value = .error(error: error)
            })

    }
    
    fileprivate func login() -> Observable<Bool> {
        loadStatus.value = .loading
        return client.login(email: email.value, password: password.value)
            .do(onNext: { [unowned self] (token) in
                self.loadStatus.value = .none
                }, onError: { [unowned self] error in
                let error = error as? KratosError ?? KratosError.unknown
                self.loadStatus.value = .error(error: error)
            })
            .map {
                if KeychainManager.create($0) {
                    return true
                } else {
                    throw KratosError.invalidSerialization
                }}
    }
    
    func binds() {
        forgotPasswordButtonTap.asObservable()
            .map{ ViewState.forgotPassword }
            .bind(to: self.viewState)
            .disposed(by: disposeBag)
        
        signInSignUpButtonTap.asObservable()
            .map { self.viewState.value }
            .map {
                switch $0 {
            case .login:
                return .registration
            case .registration, .forgotPassword:
                return .login
                }}
            .bind(to: self.viewState)
            .disposed(by: disposeBag)
        
        loginButtonTap.asObservable()
            .map { self.viewState.value }
            .subscribe(onNext: { [unowned self] state in
                switch state {
                case .login:
                    self.login()
                        .bind(to: self.loginSuccessful)
                        .disposed(by: self.disposeBag)
                case .registration:
                    Observable.combineLatest(self.email.asObservable(), self.password.asObservable(), resultSelector: { credentials in
                        return credentials
                    })
                    .bind(to: self.registrationContinueSuccessful)
                    .disposed(by: self.disposeBag)
                case .forgotPassword:
                    self.postForgotPassword()
                        .bind(to: self.forgotPasswordSuccessful)
                        .disposed(by: self.disposeBag)
                }
            })
            .disposed(by: disposeBag)
    }
}
