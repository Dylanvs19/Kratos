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
    let state = Variable<ExploreController.State>(.senate)
    let houseBills = Variable<[Bill]>([])
    let senateBills = Variable<[Bill]>([])
    let trendingBills = Variable<[Bill]>([])
    let inRecess = Variable<Bool>(false)
    
    // MARK: - Initializer -
    init(client: Client) {
        self.client = client
        fetchSenateBills()
        fetchHouseBills()
        fetchDetermineRecess()
    }
    
    // MARK: - Client Requests -
    func fetchDetermineRecess() {
        loadStatus.value = .loading
        client.determineRecess()
            .subscribe(onNext: { [weak self] inRecess in
                self?.loadStatus.value = .none
                self?.inRecess.value = inRecess
            }, onError: { [weak self] error in
                self?.loadStatus.value = .error(KratosError.cast(from: error))
            })
            .disposed(by: disposeBag)
    }
    
    func fetchSenateBills() {
        loadStatus.value = .loading
        client.fetchOnFloor(with: .senate)
            .subscribe(onNext: { [weak self] bills in
                self?.loadStatus.value = .none
                self?.senateBills.value = bills
            }, onError: { [weak self] error in
                self?.loadStatus.value = .error(KratosError.cast(from: error))
            })
            .disposed(by: disposeBag)
        
    }
    func fetchHouseBills() {
        loadStatus.value = .loading
        client.fetchOnFloor(with: .house)
            .subscribe(onNext: { [weak self] bills in
                self?.loadStatus.value = .none
                self?.houseBills.value = bills
                }, onError: { [weak self] error in
                    self?.loadStatus.value = .error(KratosError.cast(from: error))
            })
            .disposed(by: disposeBag)
    }
    
    func fetchTrendingBills() {
        loadStatus.value = .loading
        client.fetchTrending()
            .subscribe(onNext: { [weak self] bills in
                self?.loadStatus.value = .none
                self?.trendingBills.value = bills
                }, onError: { [weak self] error in
                    self?.loadStatus.value = .error(KratosError.cast(from: error))
            })
            .disposed(by: disposeBag)
    }
}
