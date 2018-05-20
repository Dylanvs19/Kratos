//
//  YourRepsViewModel.swift
//  Kratos
//
//  Created by Dylan Straughan on 5/31/17.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class UserRepsViewModel {
    // MARK: - Properties -
    let client: Client
    let disposeBag = DisposeBag()
    let loadStatus = Variable<LoadStatus>(.none)
    
    let user = ReplaySubject<User>.create(bufferSize: 1)
    let district = ReplaySubject<District>.create(bufferSize: 1)
    let state = ReplaySubject<State>.create(bufferSize: 1)
    let representatives = BehaviorSubject<[Person]>(value: [])
    let url = Variable<String?>(nil)
    
    let repSelected = PublishSubject<Person>()
    
    // MARK: - Initialization -
    init(client: Client) {
        self.client = client
        bind()
    }
    
    // MARK: - Client Requests -
    func fetchRepresentatives(from district: District) {
        client.fetchRepresentatives(state: district.state.rawValue, district: district.district)
            .subscribe(
                onNext: { [unowned self] reps in
                        self.loadStatus.value = .none
                        self.representatives.onNext(reps)
                },
                onError: { [unowned self] (error) in
                    self.loadStatus.value = .error(KratosError.cast(from: error))
                }
            )
            .disposed(by: disposeBag)
    }
    
    func fetchStateImage(state: State) {
        client.fetchStateImage(state: state)
            .subscribe(
                onNext: { [unowned self] url in
                    self.loadStatus.value = .none
                    self.url.value = url
                },
                onError: { [unowned self] (error) in
                    self.url.value = nil
                    self.loadStatus.value = .error(KratosError.cast(from: error))
                }
            )
            .disposed(by: disposeBag)
    }
}
// MARK: - RxBinder -
extension UserRepsViewModel: RxBinder {
    func bind() {
        client.user
            .filterNil()
            .bind(to: user)
            .disposed(by: disposeBag)
        
        user
            .map { $0.presentingDistrict.state }
            .bind(to: state)
            .disposed(by: disposeBag)
        
        user
            .map { $0.presentingDistrict }
            .bind(to: district)
            .disposed(by: disposeBag)
        
        district
            .subscribe(onNext: { [unowned self] in self.fetchRepresentatives(from: $0) })
            .disposed(by: disposeBag)
        
        state
            .subscribe(onNext: { [unowned self] in self.fetchStateImage(state: $0) })
            .disposed(by: disposeBag)
    }
}
