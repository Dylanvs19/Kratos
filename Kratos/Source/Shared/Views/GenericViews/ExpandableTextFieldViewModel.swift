//
//  ExpandableTextFieldViewModel.swift
//  Kratos
//
//  Created by Dylan Straughan on 6/24/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class ExpandableTextFieldViewModel {
    // MARK: - Variables -
    // Standard
    let disposeBag = DisposeBag()
    let state = Variable<ExpandableTextFieldView.State>(.contracted)
    
    // Interactions
    let toggleButtonPressed = PublishSubject<Void>()
    
    // Data
    let title = Variable<String?>(nil)
    let text = Variable<String>("")
    let buttonTitle = Variable<String>("")
    
    // MARK: - Initializer -
    init() {
        bind()
    }
    
    // MARK: - Configuration -
    func set(_ title: String) {
        self.title.value = title
    }
    
    func update(with text: String) {
        self.text.value = text
    }
}

// MARK: - Binds -
extension ExpandableTextFieldViewModel: RxBinder {
    func bind() {
        toggleButtonPressed.asObservable()
            .withLatestFrom(state.asObservable())
            .map { $0 == .expanded ? .contracted : .expanded }
            .bind(to: state)
            .disposed(by: disposeBag)
    }
}
