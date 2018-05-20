//
//  RepresentativeCellViewModel.swift
//  Kratos
//
//  Created by Dylan Straughan on 8/3/17.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//

import Foundation
import RxSwift

class RepresentativeCellViewModel {
    // MARK: - Variables -
    // Standard
    let disposeBag = DisposeBag()
    // Data
    let vote = ReplaySubject<Vote>.create(bufferSize: 1)
    let rep = ReplaySubject<LightPerson>.create(bufferSize: 1)
    
    let name = Variable<String>("")
    let stateChamber = Variable<String>("")
    let party = PublishSubject<Party>()
    let imageURL = Variable<String?>(nil)
    let voteValue = Variable<VoteValue?>(nil)
    
    // MARK: - Initialization -
    init() {
        bind()
    }
    // MARK: - Configuration -
    func update(with vote: Vote) {
        self.vote.onNext(vote)
    }
    
    func update(with representative: Person) {
        self.rep.onNext(representative.lightPerson)
    }
}

// MARK: - Binds -
extension RepresentativeCellViewModel: RxBinder {
    func bind() {
        vote
            .map { $0.person }
            .filterNil()
            .bind(to: rep)
            .disposed(by: disposeBag)
        
        vote
            .map { $0.voteValue }
            .bind(to: voteValue)
            .disposed(by: disposeBag)
        
        rep
            .map { "\($0.state.rawValue) \($0.representativeType?.rawValue ?? "")"}
            .bind(to: stateChamber)
            .disposed(by: disposeBag)
        
        rep
            .map { $0.party ?? .independent }
            .bind(to: party)
            .disposed(by: disposeBag)
        
        rep
            .map { $0.imageURL }
            .bind(to: imageURL)
            .disposed(by: disposeBag)
        
        rep
            .map { $0.fullName }
            .bind(to: name)
            .disposed(by: disposeBag)
    }
}
