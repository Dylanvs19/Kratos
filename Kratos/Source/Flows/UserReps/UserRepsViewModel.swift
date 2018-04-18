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
    
    let user = Variable<User?>(nil)
    let district = Variable<District?>(nil)
    let state = Variable<String>("")
    let representatives = Variable<[Person]>([])
    let districtModels = Variable<[[District]]>([])
    let selectedDistrict = Variable<District?>(nil)
    let query = Variable<String>("")
    let url = Variable<String?>(nil)
    
    let repSelected = PublishSubject<Person>()
    
    // MARK: - Initialization -
    init(client: Client) {
        self.client = client
        bind()
    }
    
    // MARK: - Client Requests -
    func fetchRepresentatives(from state: String, district: Int) {
        client.fetchRepresentatives(state: state, district: district)
            .subscribe(
                onNext: { [weak self] reps in
                        self?.loadStatus.value = .none
                        self?.representatives.value = reps
                },
                onError: { [weak self] (error) in
                    self?.loadStatus.value = .error(KratosError.cast(from: error))
                }
            )
            .disposed(by: disposeBag)
    }
    func fetchStateImage(state: State) {
        client.fetchStateImage(state: state)
            .subscribe(
                onNext: { [weak self] url in
                    self?.loadStatus.value = .none
                    self?.url.value = url
                },
                onError: { [weak self] (error) in
                    self?.loadStatus.value = .error(KratosError.cast(from: error))
                }
            )
            .disposed(by: disposeBag)
    }
}
// MARK: - RxBinder -
extension UserRepsViewModel: RxBinder {
    func bind() {
        client.user
            .asObservable()
            .debug()
            .bind(to: user)
            .disposed(by: disposeBag)
        user
            .asObservable()
            .filterNil()
            .subscribe(
                onNext: { [weak self] user in
                    guard let `self` = self else { fatalError("`self` deallocated before it was accessed") }
                    self.district.value = user.district
                    self.state.value = user.address.state
                    self.fetchRepresentatives(from: user.address.state, district: user.district.district)
                }
            )
            .disposed(by: disposeBag)
        state
            .asObservable()
            .map { State(rawValue: $0) }
            .filterNil()
            .subscribe(
                onNext: { [weak self] state in
                    self?.fetchStateImage(state: state)
                }
            )
            .disposed(by: disposeBag)
    }
}
