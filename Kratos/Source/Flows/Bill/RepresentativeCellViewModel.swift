//
//  RepresentativeCellViewModel.swift
//  Kratos
//
//  Created by Dylan Straughan on 8/3/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import RxSwift

class RepresentativeCellViewModel {
    // MARK: - Variables -
    // Standard
    let disposeBag = DisposeBag()
    // Data
    let vote = Variable<Vote?>(nil)
    let rep = Variable<LightPerson?>(nil)
    
    let name = Variable<String>("")
    let stateChamber = Variable<String>("")
    let party = Variable<String>("")
    let imageURL = Variable<URL?>(nil)
    let voteValue = Variable<VoteValue?>(nil)
    
    // MARK: - Initialization -
    init() {
        bind()
    }
    // MARK: - Configuration -
    func update(with vote: Vote) {
        self.vote.value = vote
    }
    
    func update(with representative: Person) {
        self.rep.value = representative.lightPerson
    }
}

// MARK: - Binds -
extension RepresentativeCellViewModel: RxBinder {
    func bind() {
        vote.asObservable()
            .map { $0?.person }
            .bind(to: rep)
            .disposed(by: disposeBag)
        
        vote.asObservable()
            .map { $0?.voteValue }
            .bind(to: voteValue)
            .disposed(by: disposeBag)
        
        rep.asObservable()
            .filterNil()
            .subscribe(onNext: { [weak self] person in
                var stateChamber = ""
                stateChamber += person.state.rawValue
                stateChamber += " "
                stateChamber += person.representativeType?.rawValue ?? ""
                self?.stateChamber.value = stateChamber
                self?.party.value = person.party?.capitalLetter ?? ""
                if let string = person.imageURL,
                   let url = URL(string: string) {
                    self?.imageURL.value = url
                }
                self?.name.value = person.fullName
            })
            .disposed(by: disposeBag)
    }
}
