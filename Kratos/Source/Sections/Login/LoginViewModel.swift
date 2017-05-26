//
//  LoginViewModel.swift
//  Kratos
//
//  Created by Dylan Straughan on 5/10/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

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
    let email = Variable<String>("hi")
    let password = Variable<String>("")
    
    let loginButtonTap = PublishSubject<Void>()
    let forgotPasswordButtonTap = PublishSubject<Void>()
    let signInSignUpButtonTap = PublishSubject<Void>()
    
    let nextViewController = PublishSubject<UIViewController>()
    
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
    
    fileprivate func postForgotPassword() {
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
    
    fileprivate func login() {
        loadStatus.value = .loading
        client.login(email: email.value, password: password.value)
            .subscribe(onNext: { [unowned self] (token, user) in
                self.loadStatus.value = .none
                let success = KeychainManager.create(token)
                if success {
                    let navVC = UINavigationController(rootViewController: TabBarController())
                    UIApplication.shared.delegate?.rootTransition(to: navVC)
                } else {
                    self.loadStatus.value = .error(error:KratosError.invalidSerialization)
                }
                
                }, onError: { [unowned self] error in
                let error = error as? KratosError ?? KratosError.unknown
                self.loadStatus.value = .error(error: error)
            })
            .disposed(by: disposeBag)
    }
    
    func binds() {
        forgotPasswordButtonTap.asObservable()
            .subscribe(onNext: { [unowned self] (tap) in
                self.viewState.value = .forgotPassword
            })
            .disposed(by: disposeBag)
        
        signInSignUpButtonTap.asObservable()
            .map { self.viewState.value }
            .map {
                switch $0 {
            case .login:
                return .registration
            case .registration:
                return .login
            case .forgotPassword:
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
                case .registration:
                    let vc = AccountDetailsViewController(client: self.client, state: .registration)
                    vc.setInfoFromRegistration(email: self.email.value, password: self.password.value)
                    self.nextViewController.onNext(vc)
                case .forgotPassword:
                    self.postForgotPassword()
                }
            })
            .disposed(by: disposeBag)
    }
}
