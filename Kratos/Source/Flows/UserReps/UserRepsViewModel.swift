//
//  YourRepsViewModel.swift
//  Kratos
//
//  Created by Dylan Straughan on 5/31/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
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
    let district = Variable<Int?>(nil)
    let state = Variable<String>("")
    let stateImage = Variable<UIImage>(#imageLiteral(resourceName: "Image_WashingtonDC"))
    let representatives = Variable<[Person]>([])
    
    let repSelected = PublishSubject<Person>()
    
    // MARK: - Initialization -
    init(client: Client) {
        self.client = client
        bind()
        fetchUser()
    }
    
    // MARK: - Client Requests -
    func fetchUser() {
        loadStatus.value = .loading
        client.fetchUser()
            .subscribe(
                onNext: { [weak self] user in
                    self?.user.value = user
                },
                onError: { [weak self] (error) in
                    self?.loadStatus.value = .error(KratosError.cast(from: error))
                }
            )
            .disposed(by: disposeBag)
    }
    
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
}
// MARK: - RxBinder -
extension UserRepsViewModel: RxBinder {
    func bind() {
        user
            .asObservable()
            .filterNil()
            .subscribe(
                onNext: { [weak self] user in
                    guard let `self` = self else { fatalError("`self` deallocated before it was accessed") }
                    self.district.value = user.district
                    self.state.value = user.address.state
                    self.fetchRepresentatives(from: user.address.state, district: user.district)
                }
            )
            .disposed(by: disposeBag)
    }
}
