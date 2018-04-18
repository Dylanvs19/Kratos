//
//  DistrictChangeViewModel.swift
//  Kratos
//
//  Created by Dylan Straughan on 1/8/18.
//  Copyright © 2018 Dylan Straughan. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class DistrictChangeViewModel {
    // MARK: - Properties -
    let client: Client
    let disposeBag = DisposeBag()
    let loadStatus = Variable<LoadStatus>(.none)
    
    let user = Variable<User?>(nil)
    let districtModels = Variable<[[District]]>([])
    let presentedDistrict = Variable<District?>(nil)
    let selectedDistrict = Variable<District?>(nil)
    let query = Variable<String>("")
    let url = Variable<String?>(nil)
    
    let showReturnHomeButton = Variable<Bool>(false)

    // MARK: - Initialization -
    init(client: Client) {
        self.client = client
        bind()
    }
    
    // MARK: - Client Requests -
    func fetchDistricts(from query: String) {
        client.fetchDistricts(from: query)
            .map {$0.grouped(groupBy: { district -> String in district.state.rawValue })}
            .subscribe(
                onNext: { [weak self] districtsArray in
                    self?.loadStatus.value = .none
                    self?.districtModels.value = districtsArray
                },
                onError: { [weak self] (error) in
                    self?.loadStatus.value = .error(KratosError.cast(from: error))
                }
            )
            .disposed(by: disposeBag)
    }
    func updateDistrict() {
        guard let user = client.user.value,
              let district = presentedDistrict.value else { return }
        var cpy = user
        cpy.visitingDistrict = district
        client.user.value = cpy
    }
}
// MARK: - RxBinder -
extension DistrictChangeViewModel: RxBinder {
    func bind() {
        client.user
            .asObservable()
            .bind(to: user)
            .disposed(by: disposeBag)
        user
            .asObservable()
            .filterNil()
            .subscribe(
                onNext: { [weak self] user in
                    guard let `self` = self else { return }
                    self.presentedDistrict.value = user.district
                }
            )
            .disposed(by: disposeBag)
        user
            .asObservable()
            .filterNil()
            .map { $0.visitingDistrict ?? $0.district }
            .bind(to: presentedDistrict)
            .disposed(by: disposeBag)
        user
            .asObservable()
            .filterNil()
            .map { $0.visitingDistrict != nil }
            .bind(to: showReturnHomeButton)
            .disposed(by: disposeBag)
        query
            .asObservable()
            .debounce(2, scheduler: MainScheduler.instance)
            .debug()
            .subscribe(
                onNext: { [weak self] query in
                    guard let `self` = self else { return }
                    self.fetchDistricts(from: query)
                }
            )
            .disposed(by: disposeBag)
       
    }
}
