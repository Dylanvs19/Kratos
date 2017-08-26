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
    
    // MARK: - Variables -
    fileprivate var client: Client
    fileprivate let disposeBag = DisposeBag()
    fileprivate var fetchDisposeBag = DisposeBag()
    
    let loginLoadStatus = Variable<LoadStatus>(.none)
    let forgotPasswordLoadStatus = Variable<LoadStatus>(.none)
    let state = Variable<LoginController.State>(.login)
    let email = Variable<String>("")
    let password = Variable<String>("")
    
    let emailValid = Variable<Bool>(false)
    let passwordValid = Variable<Bool>(false)
    let formValid = Variable<Bool>(false)
    
    let loginButtonTap = PublishSubject<Void>()
    let forgotPasswordButtonTap = PublishSubject<Void>()
    let signInSignUpButtonTap = PublishSubject<Void>()
    
    let loginSuccessful = PublishSubject<Void>()
    let forgotPasswordSuccessful = PublishSubject<Bool>()
    let pushCreateAccount = PublishSubject<(email: String, password: String)>()
    
    let user = Variable<User?>(nil)
    
    // MARK: - Initialization -
    init(client: Client) {
        self.client = client
        binds()
    }
    
    func postForgotPassword() {
        forgotPasswordLoadStatus.value = .loading
        client.forgotPassword(email: email.value)
            .subscribe(onNext: { [unowned self] (bool) in
                self.forgotPasswordLoadStatus.value = .none
                //Show Alert saying Email has been sent to Email Account
            }, onError: { [unowned self] error in
                let error = error as? KratosError ?? KratosError.unknown
                self.forgotPasswordLoadStatus.value = .error(error: error)
            })
            .disposed(by: disposeBag)
    }
    
    func login() {
        loginLoadStatus.value = .loading
        client.login(email: email.value, password: password.value)
            .subscribe(onNext: { [unowned self] state in
                self.loginLoadStatus.value = .none
                }, onError: { [unowned self] error in
                    let error = error as? KratosError ?? KratosError.unknown
                    self.loginLoadStatus.value = .error(error: error)
            })
            .disposed(by: disposeBag)
    }
    
    func binds() {
        loginButtonTap
            .map { _ in self.state.value }
            .filter { $0 == .createAccount }
            .subscribe(onNext: { [weak self] state in
                guard let `self` = self else { fatalError("self deallocated before it was accessed") }
                self.pushCreateAccount.onNext((self.email.value, self.password.value))
            })
            .disposed(by: disposeBag)
        forgotPasswordButtonTap.asObservable()
            .map{ LoginController.State.forgotPassword }
            .bind(to: self.state)
            .disposed(by: disposeBag)
        signInSignUpButtonTap.asObservable()
            .map { self.state.value }
            .map {
                switch $0 {
            case .login:
                return .createAccount
            case .createAccount, .forgotPassword:
                return .login
                }}
            .bind(to: self.state)
            .disposed(by: disposeBag)
        email.asObservable()
            .map { $0.isValid(for: .email) }
            .bind(to: emailValid)
            .disposed(by: disposeBag)
        password.asObservable()
            .map { $0.isValid(for: .email) }
            .bind(to: passwordValid)
            .disposed(by: disposeBag)
        Observable.combineLatest(emailValid.asObservable(), passwordValid.asObservable()) { $0 && $1 }
            .bind(to: formValid)
            .disposed(by: disposeBag)
    }
}
