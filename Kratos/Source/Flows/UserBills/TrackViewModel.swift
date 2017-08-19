//
//  UserBillsViewModel.swift
//  Kratos
//
//  Created by Dylan Straughan on 8/1/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


class TrackViewModel {
    
    let client: Client
    let disposeBag = DisposeBag()
    let loadStatus = Variable<LoadStatus>(.none)
    
    let user = Variable<User?>(nil)
    
    let repSelected = PublishSubject<Person>()
    
    init(client: Client) {
        self.client = client
        bind()
    }
    
    func fetchUser() -> Observable<User> {
        loadStatus.value = .loading
        return client.fetchUser()
            .do(onNext: { [unowned self] user in
                self.loadStatus.value = .none
                }, onError: { [unowned self] (error) in
                    let error = error as? KratosError ?? KratosError.unknown
                    self.loadStatus.value = .error(error: error)
            })
    }
    
    func fetchRepresentatives(from state: String, district: Int) -> Observable<[Person]> {
        loadStatus.value = .loading
        return client.fetchRepresentatives(state: state, district: district)
            .do(onNext: { [unowned self] _ in
                self.loadStatus.value = .none
                }, onError: { [unowned self] (error) in
                    let error = error as? KratosError ?? KratosError.unknown
                    self.loadStatus.value = .error(error: error)
            })
    }
}

extension TrackViewModel: RxBinder {
    
    func bind() {
        fetchUser().asObservable()
            .bind(to: user)
            .disposed(by: disposeBag)
        
    }
}
