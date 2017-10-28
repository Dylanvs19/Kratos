//
//  ConfirmationViewModel.swift
//  Kratos
//
//  Created by Dylan Straughan on 5/24/17.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//

import Foundation
import RxSwift

class ConfirmationViewModel {
    // MARK: - Properties -
    let client: Client
    let disposeBag = DisposeBag()
    let loadStatus = Variable<LoadStatus>(.none)
    let resendEmailLoadStatus = Variable<LoadStatus>(.none)
    
    let email = Variable<String>("")
    let password = Variable<String>("")
    let confirmation = Variable<String>("")
    let isValid = Variable<Bool>(false)
    
    // MARK: - Initializers -
    init(client: Client, email: String, password: String) {
        self.client = client
        self.email.value = email
        self.password.value = password
        bind()
    }
    
    // MARK: - Client Requests -
    func confirmAccount() {
        let pin = confirmation.value.replacingOccurrences(of: " ", with: "")
        loadStatus.value = .loading
        client.confirm(pin: pin)
            .subscribe(
                onNext: { [weak self] token in
                    self?.login()
                }, onError: { [weak self] error in
                    self?.loadStatus.value = .error(KratosError.cast(from: error))
                }
            )
            .disposed(by: disposeBag)
    }
    
    fileprivate func login() {
        client.login(email: email.value, password: password.value)
            .subscribe(
                onNext: { [weak self] token in
                    self?.loadStatus.value = .none
                }, onError: { [weak self] error in
                    self?.loadStatus.value = .error(KratosError.cast(from: error))
                }
            )
            .disposed(by: disposeBag)
    }
    
    func resendCode() {
        resendEmailLoadStatus.value = .loading
        client.resentConfirmation(email: email.value)
            .subscribe(
                onNext: { [weak self] token in
                    self?.resendEmailLoadStatus.value = .none
                }, onError: { [weak self] error in
                    self?.resendEmailLoadStatus.value = .error(KratosError.cast(from: error))
                }
            )
            .disposed(by: disposeBag)
    }
}

// MARK: - Binds -
extension ConfirmationViewModel: RxBinder {
    func bind() {
        confirmation
            .asObservable()
            .map { $0.replacingOccurrences(of: " ", with: "").characters.count == 6 }
            .bind(to: isValid)
            .disposed(by: disposeBag)
    }
}
