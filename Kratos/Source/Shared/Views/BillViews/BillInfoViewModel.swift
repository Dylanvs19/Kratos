//
//  BillInfoViewModel.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/12/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//


import Foundation
import UIKit
import RxSwift

class BillInfoViewModel {
    
    // MARK: - Variables -
    // Standard
    let disposeBag = DisposeBag()
    
    // Data
    let state = Variable<BillInfoView.State>(.summary)
    let bill = Variable<Bill?>(nil)
    let contentOffset = PublishSubject<CGFloat>()
    
    // MARK: - Initialization -
    init() {
        bind()
    }
    
    // MARK: - Update -
    func update(with bill: Bill) {
        self.bill.value = bill
    }
}

// MARK: - Binds -
extension BillInfoViewModel: RxBinder {
    func bind() {
    
    }
}
