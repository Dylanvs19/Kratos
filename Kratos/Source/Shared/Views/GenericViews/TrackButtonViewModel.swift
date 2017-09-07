//
//  TrackButtonViewModel.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/30/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class TrackButtonViewModel {
    
    // MARK: - Variables - 
    let client: Client
    let loadStatus = Variable<LoadStatus>(.none)
    let disposeBag = DisposeBag()
    
    // Data
    let billId = Variable<Int?>(nil)
    let state = Variable<TrackButton.State>(.untracked)
    
    // Interaction
    let buttonPressed = PublishSubject<Void>()
    
    // MARK: - Initialization -
    init(with client: Client, billId: Int) {
        self.client = client
        self.billId.value = billId
        
        bind()
    }
    
    // MARK: - Client Requests -
    func setInitialState() {
        guard let billId = billId.value else { return }
        loadStatus.value = .loading
        return client.fetchTrackedBillIds()
            .subscribe(
                onNext: { [weak self] in
                self?.loadStatus.value = .none
                self?.state.value = $0.contains(billId) ? .tracked : .untracked
            },
                onError: { [weak self] (error) in
                    self?.loadStatus.value = .error(KratosError.cast(from: error))
            })
            .disposed(by: disposeBag)
    }
    
    func track() {
        guard let billId = billId.value else { return }
        loadStatus.value = .loading
        return client.trackBill(billID: billId)
            .subscribe(
                onNext: { [weak self] in
                    self?.loadStatus.value = .none
                    self?.state.value = $0.contains(billId) ? .tracked : .untracked
                },
                onError: { [weak self] (error) in
                    self?.loadStatus.value = .error(KratosError.cast(from: error))
            })
            .disposed(by: disposeBag)
    }
    
    func untrack() {
        guard let billId = billId.value else { return }
        loadStatus.value = .loading
        return client.untrackBill(billID: billId)
            .subscribe(
                onNext: { [weak self] in
                    self?.loadStatus.value = .none
                    self?.state.value = .untracked
                },
                onError: { [weak self] (error) in
                     self?.loadStatus.value = .error(KratosError.cast(from: error))
            })
            .disposed(by: disposeBag)
    }
}

extension TrackButtonViewModel: RxBinder {
    func bind() {
        buttonPressed.asObservable()
            .withLatestFrom(state.asObservable())
            .subscribe(onNext: { [weak self] isTracked in
                isTracked == .tracked ? self?.untrack() : self?.track()
            })
            .disposed(by: disposeBag)
    }
}
