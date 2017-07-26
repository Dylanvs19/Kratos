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
    
    // Main
    let id: Int
    let bill = PublishSubject<Bill>()
    
    let title = Variable<String>("")
    let status = Variable<String>("")
    let statusDate = Variable<String>("")
    
    let isTracking = Variable<Bool>(false)
    
    let trackButtonPressed = PublishSubject<Void>()
    let trackButtonLoadStatus = Variable<LoadStatus>(.none)

    // MARK: - Initialization -
    init(client: Client, billID: Int) {
        self.client = client
        self.id = billID
        bind()
    }
    
    // MARK: - Client Requests -
    func fetchBill(id: Int) -> Observable<Bill> {
        loadStatus.value = .loading
        return client.fetchBill(billID: id)
            .do(onNext: { [unowned self] _ in
                self.loadStatus.value = .none
                }, onError: { [unowned self] (error) in
                    let error = error as? KratosError ?? KratosError.unknown
                    self.loadStatus.value = .error(error: error)
            })
    }
    
    func trackBill() -> Observable<Void> {
        trackButtonLoadStatus.value = .loading
        return client.trackBill(billID: id)
            .do(onNext: { [unowned self] _ in
                self.trackButtonLoadStatus.value = .none
                }, onError: { [unowned self] (error) in
                    let error = error as? KratosError ?? KratosError.unknown
                    self.loadStatus.value = .error(error: error)
            })
    }
    
    func untrackBill() -> Observable<Void> {
        trackButtonLoadStatus.value = .loading
        return client.untrackBill(billID: id)
            .do(onNext: { [unowned self] _ in
                self.trackButtonLoadStatus.value = .none
                }, onError: { [unowned self] (error) in
                    let error = error as? KratosError ?? KratosError.unknown
                    self.loadStatus.value = .error(error: error)
            })
    }
}

// MARK: - Binds -
extension BillViewModel: RxBinder {
    
    func bind() {
        refreshData()
        
        bill.asObservable()
            .map { $0.title ?? $0.officialTitle }
            .filterNil()
            .bind(to: title)
            .disposed(by: disposeBag)
        
        bill.asObservable()
            .map { $0.status }
            .filterNil()
            .bind(to: status)
            .disposed(by: disposeBag)
        
        bill.asObservable()
            .map { $0.statusDate }
            .filterNil()
            .map { DateFormatter.presentation.string(from: $0) }
            .bind(to: statusDate)
            .disposed(by: disposeBag)
        
    }
    
    // MARK: - Initial Data Load -
    func refreshData() {
        Observable<Int>.just(id)
            .flatMap{ self.fetchBill(id: $0) }
            .bind(to: self.bill)
            .disposed(by: disposeBag)
    }
    
}
