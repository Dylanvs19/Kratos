//
//  ConfirmationViewModel.swift
//  Kratos
//
//  Created by Dylan Straughan on 5/24/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import RxSwift

class ConfirmationViewModel {
    
    let client: Client
    let disposeBag = DisposeBag()
    let loadStatus = Variable<LoadStatus>(.none)
    
    //UI Element Variables
    let title = Variable<String>("Confirmation")
    let buttonTitle = Variable<String>("Link Pressed")
    let text = Variable<String>("We have just sent an email to your email address you provided to us with a magic link. Once you have activated the link you will be signed in. If you are not automatically signed in after activating the link in the email, press the button below.")
    
    let email = Variable<String>("")
    let password = Variable<String>("")
    
    let confirmationPressed = PublishSubject<Void>()
    let push = PublishSubject<Void>()
    
    init(client: Client) {
        self.client = client
        bind()
    }
    
    fileprivate func login() {
        loadStatus.value = .loading
        return client.login(email: email.value, password: password.value)
            .subscribe(onNext: { [weak self] token in
                self?.loadStatus.value = .none
                KeychainManager.create(token)
                self?.push.onNext(())
            }, onError: { [weak self] error in
                let error = error as? KratosError ?? KratosError.unknown
                self?.loadStatus.value = .error(error: error)
            })
            .disposed(by: disposeBag)
    }
}

extension ConfirmationViewModel: RxBinder {
    func bind() {
        confirmationPressed.asObservable()
            .subscribe(onNext: { [weak self] in
                self?.login()
            })
        .disposed(by: disposeBag)
    }
}
