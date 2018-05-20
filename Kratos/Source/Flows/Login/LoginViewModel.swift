//
//  LoginViewModel.swift
//  Kratos
//
//  Created by Dylan Straughan on 5/10/17.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//

import Foundation
import RxSwift

class LoginViewModel {
    
    // MARK: - Variables -
    private var client: AuthService
    private let disposeBag = DisposeBag()
    
    let state: LoginController.State
    
    let loginLoadStatus = BehaviorSubject<LoadStatus>(value: .none)
    let forgotPasswordLoadStatus = BehaviorSubject<LoadStatus>(value: .none)
    
    let active = BehaviorSubject<Bool>(value: false)
    
    let email = Variable<String>("")
    let password = Variable<String>("")
    
    let emailValid = BehaviorSubject<Bool>(value: false)
    let passwordValid = BehaviorSubject<Bool>(value: false)
    
    let formValid = BehaviorSubject<Bool>(value: false)
    
    let credentials = Variable<(email: String, password: String)?>(nil)
    
    // MARK: - Initialization -
    init(client: Client, state: LoginController.State) {
        self.client = client
        self.state = state
        
        bind()
    }
    
    func postForgotPassword() {
        forgotPasswordLoadStatus.onNext(.loading)
        client.forgotPassword(email: email.value)
            .subscribe(
                onNext: { [unowned self] (bool) in
                    self.forgotPasswordLoadStatus.onNext(.none)
                }, onError: { [unowned self] error in
                    self.forgotPasswordLoadStatus.onNext(.error(KratosError.cast(from: error)))
                }
            )
            .disposed(by: disposeBag)
    }
    
    func login() {
        loginLoadStatus.onNext(.loading)
        client.login(email: email.value, password: password.value)
            .subscribe(
                onNext: { [unowned self] state in
                    self.loginLoadStatus.onNext(.none)
                }, onError: { [unowned self] error in
                    self.loginLoadStatus.onNext(.error(KratosError.cast(from: error)))
                }
            )
            .disposed(by: disposeBag)
    }
}

extension LoginViewModel: RxBinder {
    func bind() {
        Observable.combineLatest(email.asObservable(), password.asObservable()) { (email: $0, password: $1)}
            .bind(to: credentials)
            .disposed(by: disposeBag)
        Observable.combineLatest(emailValid, passwordValid) { $0 && $1 }
            .bind(to: formValid)
            .disposed(by: disposeBag)
        Observable.combineLatest(loginLoadStatus, forgotPasswordLoadStatus) { $0 == .loading || $1 == .loading }
            .bind(to: active)
            .disposed(by: disposeBag)
    }
}
