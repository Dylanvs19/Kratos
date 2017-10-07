//
//  BillViewModel.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/12/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


class BillViewModel {
    
    // MARK: - Properties -
    // Standard
    let client: Client
    let disposeBag = DisposeBag()
    let loadStatus = Variable<LoadStatus>(.none)
    let trackingStatus = Variable<LoadStatus>(.none)
    
    // Main
    let id = Variable<Int?>(nil)
    let bill = Variable<Bill?>(nil)
    
    let title = Variable<String>("")
    let status = Variable<String>("")
    let statusDate = Variable<String>("")
    
    let isTracking = Variable<Bool>(false)
    
    let trackButtonPressed = PublishSubject<Void>()
    let trackButtonLoadStatus = Variable<LoadStatus>(.none)

    // MARK: - Initialization -
    init(with client: Client, billId: Int) {
        self.client = client
        self.id.value = billId
        bind()
        fetchBill()
    }
    
    init(with client: Client, lightTally: LightTally) {
        self.client = client
        if let title = lightTally.billTitle {
            self.title.value = title
        }
        if let result = lightTally.result {
            self.status.value = result.presentable
        }
        if let lastRecordUpdate = lightTally.lastRecordUpdate {
            self.statusDate.value = lastRecordUpdate
        }
        if let id = lightTally.billId {
            self.id.value = id
        }
        bind()
        fetchBill()
    }
    
    init(with client: Client, bill: Bill) {
        self.client = client
        self.bill.value = bill
        self.id.value = bill.id
        bind()
        fetchBill()
    }
    
    // MARK: - Client Requests -
    func fetchBill() {
        guard let id = self.id.value else { return }
        loadStatus.value = .loading
        return client.fetchBill(billID: id)
            .subscribe(onNext: { [weak self] bill in
                self?.loadStatus.value = .none
                self?.bill.value = bill
            }, onError: { [weak self] error in
                    self?.loadStatus.value = .error(KratosError.cast(from: error))
                }
            )
            .disposed(by: disposeBag)
    }
    
    func determineTrackedStatus(for id: Int) {
        return client.fetchTrackedBillIds()
            .subscribe(
                onNext: { [weak self] ids in
                    self?.trackingStatus.value = .none
                    self?.isTracking.value = ids.contains(id)
                },
                onError: { [weak self] error in
                    self?.trackingStatus.value = .error(KratosError.cast(from: error))
                }
            )
            .disposed(by: disposeBag)
    }
    
    func track() {
        guard let billId = id.value else { return }
        trackingStatus.value = .loading
        return client.trackBill(billID: billId)
            .subscribe(
                onNext: { [weak self] _ in
                    self?.trackingStatus.value = .none
                    self?.isTracking.value = true
                },
                onError: { [weak self] error in
                    self?.trackingStatus.value = .error(KratosError.cast(from: error))
                }
            )
            .disposed(by: disposeBag)
    }
    
    func untrack() {
        guard let billId = id.value else { return }
        trackingStatus.value = .loading
        return client.untrackBill(billID: billId)
            .subscribe(
                onNext: { [weak self] _ in
                    self?.trackingStatus.value = .none
                    self?.isTracking.value = false
                },
                onError: { [weak self] error in
                    self?.trackingStatus.value = .error(KratosError.cast(from: error))
                }
            )
            .disposed(by: disposeBag)
    }
}

// MARK: - Binds -
extension BillViewModel: RxBinder {
    
    func bind() {
        bill
            .asObservable()
            .filterNil()
            .map { $0.title ?? $0.officialTitle }
            .filterNil()
            .bind(to: title)
            .disposed(by: disposeBag)
        
        bill
            .asObservable()
            .filterNil()
            .map { $0.status?.cleanStatus }
            .filterNil()
            .bind(to: status)
            .disposed(by: disposeBag)
        
        bill
            .asObservable()
            .filterNil()
            .map { $0.statusDate }
            .filterNil()
            .map { DateFormatter.presentation.string(from: $0) }
            .bind(to: statusDate)
            .disposed(by: disposeBag)
        bill
            .asObservable()
            .filterNil()
            .subscribe(onNext: { [weak self] bill in
                 self?.client.logView(type: .billViewed(id: bill.id))
                }
            )
            .disposed(by: disposeBag)
        id
            .asObservable()
            .filterNil()
            .subscribe(
                onNext: { [weak self] id in
                    self?.determineTrackedStatus(for: id)
                }
            )
            .disposed(by: disposeBag)
    }
}
