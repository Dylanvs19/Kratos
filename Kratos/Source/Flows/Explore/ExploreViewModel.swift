//
//  ExploreViewModel.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/31/17.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
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
    let state = Variable<ExploreController.State>(.trending)
    let houseBills = Variable<[Bill]>([])
    let senateBills = Variable<[Bill]>([])
    let trendingBills = Variable<[Bill]>([])
    let inRecess = Variable<Bool>(false)
    
    // MARK: - Initializer -
    init(client: Client) {
        self.client = client
        loadStatus.value = .loading
        fetchSenateBills()
        fetchHouseBills()
        fetchTrendingBills()
        fetchDetermineRecess()
        bind()
    }
    
    // MARK: - Client Requests -
    func fetchDetermineRecess() {
        client.determineRecess()
            .subscribe(
                onNext: { [weak self] inRecess in
                    self?.inRecess.value = inRecess
                },
                onError: { [weak self] error in
                    self?.loadStatus.value = .error(KratosError.cast(from: error))
                }
            )
            .disposed(by: disposeBag)
    }
    
    func fetchSenateBills() {
        
        client.fetchOnFloor(with: .senate)
            .subscribe(
                onNext: { [weak self] bills in
                    self?.senateBills.value = bills
               },
               onError: { [weak self] error in
                    self?.loadStatus.value = .error(KratosError.cast(from: error))
                }
            )
            .disposed(by: disposeBag)
        
    }
    func fetchHouseBills() {
        client.fetchOnFloor(with: .house)
            .subscribe(
                onNext: { [weak self] bills in
                    self?.houseBills.value = bills
                },
                   onError: { [weak self] error in
                        self?.loadStatus.value = .error(KratosError.cast(from: error))
                }
            )
            .disposed(by: disposeBag)
    }
    
    func fetchTrendingBills() {
        client.fetchTrending()
            .subscribe(
                onNext: { [weak self] bills in
                    self?.trendingBills.value = bills
                },
                onError: { [weak self] error in
                    self?.loadStatus.value = .error(KratosError.cast(from: error))
                }
            )
            .disposed(by: disposeBag)
    }
}

extension ExploreViewModel: RxBinder {
    func bind() {
        Observable.combineLatest(houseBills.asObservable().skip(1), senateBills.asObservable().skip(1), trendingBills.asObservable().skip(1))
            .subscribe(
                onNext: { [weak self] _ in
                    self?.loadStatus.value = .none
                }
            )
            .disposed(by: disposeBag)
    }
}


