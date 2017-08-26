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
    
    let loadStatus = Variable<LoadStatus>(.none)
    let state = Variable<LoginController.State>(.login)
    let email = Variable<String>("")
    let password = Variable<String>("")
    
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
    
    // MARK: - Variables -
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
    
    func postForgotPassword() {
        loadStatus.value = .loading
        client.forgotPassword(email: email.value)
            .subscribe(onNext: { [unowned self] (bool) in
                self.loadStatus.value = .none
                //Show Alert saying Email has been sent to Email Account
            }, onError: { [unowned self] error in
                let error = error as? KratosError ?? KratosError.unknown
                self.loadStatus.value = .error(error: error)
            })
            .disposed(by: disposeBag)

    }
    
    func login() {
        loadStatus.value = .loading
        client.login(email: email.value, password: password.value)
            .subscribe(onNext: { [unowned self] state in
                self.loadStatus.value = .none
                }, onError: { [unowned self] error in
                    let error = error as? KratosError ?? KratosError.unknown
                    self.loadStatus.value = .error(error: error)
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
    }
}
