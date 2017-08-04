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
    
    let sponsors = Variable<[String: [Person]]>([String:[Person]]())
    let tallies = Variable<[Tally]>([])
    let committees = Variable<[Committee]>([])
    let summary = Variable<String>("")
    
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
        bill.asObservable()
            .filterNil()
            .subscribe(onNext: { [weak self] bill in
                self?.tallies.value = bill.tallies ?? []
                self?.committees.value = bill.committees ?? []
                self?.summary.value = bill.summary ?? ""
                
                var sponsors = [String: [Person]]()
                if let leadSponsor = bill.sponsor {
                     sponsors["Lead Sponsor"] = [leadSponsor]
                }
                if let coSponsors = bill.coSponsors {
                    sponsors["CoSponsors"] = coSponsors
                }
                self?.sponsors.value = sponsors
            })
            .disposed(by: disposeBag)
    }
}
