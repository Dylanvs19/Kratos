//
//  LoginViewModel.swift
//  Kratos
//
//  Created by Dylan Straughan on 5/10/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import RxSwift

class LoginViewModel {
    
    // MARK: - Enums -
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
    
    // MARK: - Variables -
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
    
    let loginSuccessful = PublishSubject<Void>()
    let forgotPasswordSuccessful = PublishSubject<Bool>()
    let registrationContinueSuccessful = PublishSubject<(email: String, password: String)>()
    
    let user = Variable<User?>(nil)
    
    // MARK: - Initialization -
    init(client: Client) {
        self.client = client
        binds()
    }
    
    // MARK: - Configuration -
    var formValid : Observable<Bool> {
        return Observable.combineLatest(emailValid, passwordValid) { (email, password) in
            return email && password
        }
    }
    var emailValid : Observable<Bool> {
        return email.asObservable()
            .map { $0.isValid(for: .email) }
    }
    var passwordValid : Observable<Bool> {
        return password.asObservable()
            .map { $0.isValid(for: .password) }
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
    
    fileprivate func login() -> Observable<Void> {
        loadStatus.value = .loading
        return client.login(email: email.value, password: password.value)
            .do(
                onNext: { [unowned self] (token) in
                    self.loadStatus.value = .none
                    Store.shelve(token, key: "token")
                },
                onError: { [unowned self] error in
                    let error = error as? KratosError ?? KratosError.unknown
                    self.loadStatus.value = .error(error: error)
            })
            .map { _ in () }
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
                    self.login().asObservable()
                        .bind(to: self.loginSuccessful)
                        .disposed(by: self.disposeBag)
                case .registration:
                    self.registrationContinueSuccessful.onNext((self.email.value, self.password.value))
                case .forgotPassword:
                    self.postForgotPassword().asObservable()
                        .bind(to: self.forgotPasswordSuccessful)
                        .disposed(by: self.disposeBag)
                }
            })
            .disposed(by: disposeBag)
    }
}
