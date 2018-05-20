//
//  UserRepViewModel.swift
//  Kratos
//
//  Created by Dylan Straughan on 6/1/17.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class UserRepTableViewCellModel {
    
    let disposeBag = DisposeBag()
    
    let representative = ReplaySubject<Person>.create(bufferSize: 1)
    let name = ReplaySubject<String>.create(bufferSize: 1)
    let chamber = ReplaySubject<Chamber>.create(bufferSize: 1)
    let party = ReplaySubject<Party>.create(bufferSize: 1)
    let url = Variable<String?>(nil)
    
    init() {
        bind()
    }
    
    func update(with person: Person) {
        self.representative.onNext(person)
    }
}

extension UserRepTableViewCellModel: RxBinder {
    func bind() {
        representative
            .map { $0.fullName }
            .bind(to: name)
            .disposed(by: disposeBag)
        
        representative
            .map { $0.currentChamber }
            .bind(to: chamber)
            .disposed(by: disposeBag)
        
        representative
            .map { $0.currentParty ?? .independent }
            .bind(to: party)
            .disposed(by: disposeBag)
        
        representative
            .map { $0.imageURL }
            .bind(to: url)
            .disposed(by: disposeBag)
    }
}
