//
//  UserRepViewModel.swift
//  Kratos
//
//  Created by Dylan Straughan on 6/1/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class UserRepTableViewCellModel {
    
    let client: Client
    let disposeBag = DisposeBag()
    let representative = Variable<Person?>(nil)
    let name = Variable<String>("")
    let chamber = Variable<Chamber>(.senate)
    let partyColor = Variable<UIColor>(.slate)
    let url = Variable<URL?>(nil)
    
    init(client: Client, person: Person) {
        self.client = client
        self.representative.value = person
        bind()
    }
}

extension UserRepTableViewCellModel: RxBinder {
    func bind() {
        representative.asObservable()
            .filterNil()
            .subscribe(onNext: { [weak self] person in
                self?.name.value = person.fullName
                self?.chamber.value = person.currentChamber
                if let repParty = person.currentParty {
                    self?.partyColor.value = repParty.color.value
                }
            })
            .disposed(by: disposeBag)
        
        representative.asObservable()
            .map { $0?.imageURL }
            .filterNil()
            .map { URL(string: $0) }
            .bind(to: url)
            .disposed(by: disposeBag)
    }
}
