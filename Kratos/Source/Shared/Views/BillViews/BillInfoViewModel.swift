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
    
    //State
    let state = Variable<BillInfoView.State>(.summary)
    let bill: Observable<Bill>
    let contentOffset = Variable<CGFloat>(0)
    
    let disposeBag = DisposeBag()
    
    init(with bill: Bill) {
        self.bill = Observable.just(bill)
        
        bind()
        
        //Bind up
        self.contentOffset.asObservable()
            .bind(to: contentOffset)
            .disposed(by: disposeBag)
    }
}

extension BillInfoViewModel: RxBinder {
    func bind() {
    
    }
}
