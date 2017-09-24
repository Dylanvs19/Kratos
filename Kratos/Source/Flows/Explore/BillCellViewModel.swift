//
//  BillCellViewModel.swift
//  Kratos
//
//  Created by Dylan Straughan on 8/6/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import RxSwift

class BillCellViewModel {
    // MARK: - Variables -
    let disposeBag = DisposeBag()
    
    let bill = Variable<Bill?>(nil)
    
    let title = Variable<String>("")
    let subject = Variable<String>("")
    let lastAction = Variable<String>("")
    
    init() {
        bind()
    }
    
    func update(with bill: Bill) {
        self.bill.value = bill
    }
}

// MARK: - Binds -
extension BillCellViewModel: RxBinder {
    func bind() {
        bill
            .asObservable()
            .filterNil()
            .subscribe(onNext: { [weak self] bill in
                if let title = bill.title {
                    self?.title.value = title
                } else {
                    self?.title.value = bill.officialTitle ?? ""
                }
                var status = ""
                self?.lastAction.value = status
                if let billStatus = bill.status {
                    status += billStatus.cleanStatus
                }
                if let billStatusDate = bill.statusDate {
                    let date = DateFormatter.presentation.string(from: billStatusDate)
                    if status.isEmpty {
                        status += date
                    } else {
                        status += " - \(date)"
                    }
                }
                self?.lastAction.value = status
                self?.subject.value = bill.topSubject?.name ?? ""
            })
            .disposed(by: disposeBag)
    }
}
