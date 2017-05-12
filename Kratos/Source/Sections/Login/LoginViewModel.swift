//
//  LoginViewModel.swift
//  Kratos
//
//  Created by Dylan Straughan on 5/10/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import RxSwift

struct LoginViewModel {
    
    fileprivate let client: Client
    fileprivate let disposeBag = DisposeBag()
    fileprivate var fetchDisposeBag = DisposeBag()
    
    let loadStatus = Variable<LoadStatus>(.none)
    
    
    init(client: Client) {
        self.client = client
    }
}
