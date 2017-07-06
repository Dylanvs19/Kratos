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
import Action

class UserRepTableViewCellModel {
    
    let client: Client
    let disposeBag = DisposeBag()
    let representative = Variable<Person?>(nil)
    let name = Variable<String>("")
    let chamber = Variable<Chamber>(.senate)
    let imageURLString = Variable<String?>(nil)
    let partyColor = Variable<UIColor>(.kratosLightGray)
    
    init(client: Client, person: Person) {
        self.client = client
        self.representative.value = person
        bind()
    }
    
    func populateVariables(from representative: Person) {
        if let first = representative.firstName,
            let last = representative.lastName {
            name.value = first + " " + last
        }
        if let repParty = representative.currentParty {
            partyColor.value = repParty.color
        }
        if let repChamber = representative.currentChamber {
            chamber.value = repChamber
        }
    }
}

extension UserRepTableViewCellModel: RxBinder {
    func bind() {
        representative.asObservable()
            .filterNil()
            .subscribe(onNext: { [weak self] person in
                self?.populateVariables(from: person)
            })
            .disposed(by: disposeBag)
    }
}
