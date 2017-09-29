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
    let loadStatus = Variable<LoadStatus>(.loading)
    // Data
    let state = Variable<BillInfoView.State>(.summary)
    let bill = Variable<Bill?>(nil)
    let contentOffset = PublishSubject<CGFloat>()
    
    let sponsors = Variable<[String: [Person]]>([String:[Person]]())
    let tallies = Variable<[Tally]>([])
    let committees = Variable<[Committee]>([])
    let summary = Variable<String>("")
    let details = Variable<[(String, String)]>([])
    
    // MARK: - Initialization -
    init() {
        bind()
    }
    
    // MARK: - Update -
    func update(with bill: Bill) {
        self.bill.value = bill
        self.loadStatus.value = .none
    }
}

// MARK: - Binds -
extension BillInfoViewModel: RxBinder {
    func bind() {
        bill.asObservable()
            .filterNil()
            .subscribe(onNext: { [weak self] bill in
                if let tallies = bill.tallies {
                    self?.tallies.value = tallies.sorted(by: { ($0.date ?? Date()) > ($1.date ?? Date()) } )
                }
                self?.committees.value = bill.committees ?? []
                let summary = bill.summary ?? bill.officialTitle
                self?.summary.value = summary ?? ""
                
                var sponsors = [String: [Person]]()
                if let leadSponsor = bill.sponsor {
                     sponsors["Lead Sponsor"] = [leadSponsor]
                }
                if let coSponsors = bill.coSponsors,
                    !coSponsors.isEmpty {
                    sponsors["CoSponsors"] = coSponsors
                }
                self?.sponsors.value = sponsors
                var details: [(String, String)] = []
                if let detail = bill.officialTitle {
                    details.append(("Official Title:", detail))
                }
                if let detail = bill.introductionDate {
                    details.append(("Introduction:", DateFormatter.presentation.string(from: detail)))
                }
                if let detail = bill.committees {
                    details.append(("Committes:", detail.reduce("", { $0 + ($1.name != nil ? ", \($1.name!)" : "")})))
                }
                if let detail = bill.active {
                    details.append(("Active:", "\(detail)"))
                }
                if let detail = bill.summaryDate {
                    details.append(("Summary Date:", DateFormatter.presentation.string(from: detail)))
                }
                self?.details.value = details
            })
            .disposed(by: disposeBag)
    }
}
