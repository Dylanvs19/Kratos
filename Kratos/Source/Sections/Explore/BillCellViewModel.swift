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
    
    let bill = Variable<LightBill?>(nil)
    
    let title = Variable<String>("")
    let prettyGpo = Variable<String>("")
    
    init() {
        bind()
    }
    
    func update(with bill: LightBill) {
        self.bill.value = bill
    }
}

// MARK: - Binds -
extension BillCellViewModel: RxBinder {
    func bind() {
        bill.asObservable()
            .filterNil()
            .subscribe(onNext: { [weak self] bill in
                self?.title.value = bill.title
                self?.prettyGpo.value = bill.prettyGpoId
            })
            .disposed(by: disposeBag)
    }
}
