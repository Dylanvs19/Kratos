//
//  ExploreViewModel.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/31/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


class ExploreViewModel {
    
    let client: Client
    let disposeBag = DisposeBag()
    let loadStatus = Variable<LoadStatus>(.none)
    
    let user = Variable<User?>(nil)
    let district = Variable<Int?>(nil)
    let state = Variable<String>("")
    let stateImage = Variable<UIImage>(#imageLiteral(resourceName: "Image_WashingtonDC"))
    let representatives = Variable<[Person]>([])
    
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

extension ExploreViewModel: RxBinder {
    
    func bind() {
        fetchUser().asObservable()
            .bind(to: user)
            .disposed(by: disposeBag)
        
        user.asObservable()
            .filterNil()
            .subscribe(onNext: { [weak self] (user) in
                guard let s = self else { fatalError("`self` deallocated before it was accessed") }
                
                s.district.value = user.district
                s.state.value = user.address.state
                
                s.fetchRepresentatives(from: user.address.state, district: user.district)
                    .bind(to: s.representatives)
                    .disposed(by: s.disposeBag)
            })
            .disposed(by: disposeBag)
        
    }
}