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
        bind()
    }
    
    // MARK: - Client Requests -
    func fetchBill() {
        guard let id = self.id.value else { return }
        loadStatus.value = .loading
        return client.fetchBill(billID: id)
            .subscribe(onNext: { [unowned self] bill in
                self.loadStatus.value = .none
                self.bill.value = bill
            }, onError: { [unowned self] (error) in
                    let error = error as? KratosError ?? KratosError.unknown
                    self.loadStatus.value = .error(error: error)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Binds -
extension BillViewModel: RxBinder {
    
    func bind() {
        bill.asObservable()
            .filterNil()
            .map { $0.title ?? $0.officialTitle }
            .filterNil()
            .bind(to: title)
            .disposed(by: disposeBag)
        
        bill.asObservable()
            .filterNil()
            .map { $0.status }
            .filterNil()
            .bind(to: status)
            .disposed(by: disposeBag)
        
        bill.asObservable()
            .filterNil()
            .map { $0.statusDate }
            .filterNil()
            .map { DateFormatter.presentation.string(from: $0) }
            .bind(to: statusDate)
            .disposed(by: disposeBag)
    }
}
