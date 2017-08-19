//
//  ExploreViewModel.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/31/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


class ExploreViewModel {
    
    // MARK: - Enums -
    enum State {
        case house
        case senate
    }
    
    let client: Client
    let disposeBag = DisposeBag()
    let loadStatus = Variable<LoadStatus>(.none)
    
    let district = Variable<Int?>(nil)
    let state = Variable<Chamber>(.house)
    let representatives = Variable<[Person]>([])
    
    let repSelected = PublishSubject<Person>()
    
    init(client: Client) {
        self.client = client
        bind()
    }
}

extension ExploreViewModel: RxBinder {
    
    func bind() {
        
    }
}
