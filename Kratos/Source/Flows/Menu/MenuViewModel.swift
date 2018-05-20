//
//  MenuViewModel.swift
//  Kratos
//
//  Created by Dylan Straughan on 5/5/18.
//  Copyright © 2018 Dylan Straughan. All rights reserved.
//

import Foundation
import RxSwift

struct MenuViewModel {
    
    let client: UserService & AuthService
    let disposeBag = DisposeBag()
    let user = ReplaySubject<User>.create(bufferSize: 1)
    
    init(client: UserService & AuthService) {
        self.client = client
        bind()
    }
    
    func logOut() {
        client.logOut()
    }
}

extension MenuViewModel: RxBinder {
    func bind() {
        client.user
            .filterNil()
            .bind(to: user)
            .disposed(by: disposeBag)
    }
}
