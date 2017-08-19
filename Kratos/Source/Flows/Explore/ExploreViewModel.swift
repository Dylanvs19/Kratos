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
    // MARK: - Variables -
    // Standard
    let client: Client
    let disposeBag = DisposeBag()
    let loadStatus = Variable<LoadStatus>(.none)
    
    // Data
    let state = Variable<ExploreController.State>(.house)
    let houseBills = Variable<[Bill]>([])
    let senateBills = Variable<[Bill]>([])
    
    // MARK: - Initializer -
    init(client: Client) {
        self.client = client
        fetchSenateBills()
        fetchHouseBills()
    }
    
    // MARK: - Service Calls -
    func fetchSenateBills() {
        loadStatus.value = .loading
        client.fetchOnFloor(with: .senate)
            .debug()
            .subscribe(onNext: { [weak self] bills in
                self?.loadStatus.value = .none
                self?.senateBills.value = bills
            }, onError: { [weak self] error in
                guard let error = error as? KratosError else { return }
                self?.loadStatus.value = .error(error: error)
            })
            .disposed(by: disposeBag)
        
    }
    func fetchHouseBills() {
        loadStatus.value = .loading
        client.fetchOnFloor(with: .house)
            .debug()
            .subscribe(onNext: { [weak self] bills in
                self?.loadStatus.value = .none
                self?.houseBills.value = bills
                }, onError: { [weak self] error in
                    guard let error = error as? KratosError else { return }
                    self?.loadStatus.value = .error(error: error)
            })
            .disposed(by: disposeBag)
    }
}