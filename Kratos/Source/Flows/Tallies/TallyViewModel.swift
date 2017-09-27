//
//  TallyViewModel.swift
//  Kratos
//
//  Created by Dylan Straughan on 9/5/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class TallyViewModel {
    
    // MARK: - Variables -
    let client: Client
    let disposeBag = DisposeBag()
    var billsDisposeBag: DisposeBag? = DisposeBag()
    let loadStatus = Variable<LoadStatus>(.none)
    let state = Variable<TallyController.State>(.votes)
    
    let lightTally = Variable<LightTally?>(nil)
    let tally = Variable<Tally?>(nil)
    
    let pieChartData = Variable<[PieChartData]?>([])
    let title = Variable<String>("")
    let status = Variable<String>("")
    let statusDate = Variable<String>("")
    let votes = Variable<[Vote]>([])
    
    init(client: Client, lightTally: LightTally) {
        self.client = client
        self.lightTally.value = lightTally
        bind()
        
    }
    
    init(client: Client, tally: Tally) {
        self.client = client
        self.tally.value = tally
        bind()
    }
    
    func fetchTally(with id: Int) {
        loadStatus.value = .loading
        client.fetchTally(lightTallyID: id)
            .subscribe(onNext: { [weak self] tally in
                self?.loadStatus.value = .none
                self?.tally.value = tally
            }, onError: { [weak self] error in
                self?.loadStatus.value = .error(KratosError.cast(from: error))
            })
            .disposed(by: disposeBag)
    }
}

extension TallyViewModel: RxBinder {
    func bind() {
        lightTally.asObservable()
            .filterNil()
            .map { $0.id }
            .subscribe(onNext: { [weak self] lightTallyId in
                self?.fetchTally(with: lightTallyId)
            })
            .disposed(by: disposeBag)
        tally
            .asObservable()
            .filterNil()
            .subscribe(
                onNext: { [weak self] tally in
                    self?.title.value = tally.question ?? tally.subject ?? ""
                    self?.pieChartData.value = [PieChartData(with: tally.yea ?? 0, type: .yea),
                                                PieChartData(with: tally.nay ?? 0, type: .nay),
                                                PieChartData(with: tally.abstain ?? 0, type: .abstain)]
                    self?.status.value = tally.resultText ?? ""
                    if let date = tally.date {
                        self?.statusDate.value = DateFormatter.presentation.string(from: date)
                    }
                    self?.votes.value = tally.votes ?? []
                }
            )
            .disposed(by: disposeBag)
    }
}
