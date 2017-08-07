//
//  TallyCellViewModel.swift
//  Kratos
//
//  Created by Dylan Straughan on 8/4/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import RxSwift

class TallyCellViewModel {
    // MARK: - Variables -
    let disposeBag = DisposeBag()
    
    let tally = Variable<Tally?>(nil)
    
    let pieChartData = Variable<[PieChartData]?>([])
    let name = Variable<String>("")
    let status = Variable<String>("")
    let statusDate = Variable<String>("")
    
    init() {
        bind()
    }
    
    func update(with tally: Tally) {
        self.tally.value = tally
    }
}

// MARK: - Binds -
extension TallyCellViewModel: RxBinder {
    func bind() {
        tally.asObservable()
            .filterNil()
            .subscribe(onNext: { [weak self] tally in
                
                self?.pieChartData.value = [PieChartData(with: tally.yea ?? 0, type: .yea),
                                            PieChartData(with: tally.nay ?? 0, type: .nay),
                                            PieChartData(with: tally.abstain ?? 0, type: .abstain)]
                
                self?.name.value = tally.question ?? ""
                self?.status.value = tally.result?.presentable ?? ""
                if let date = tally.date {
                    self?.statusDate.value = DateFormatter.presentation.string(from: date)
                }
            })
            .disposed(by: disposeBag)
    }
}
