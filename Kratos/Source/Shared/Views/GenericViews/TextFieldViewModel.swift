//
//  TextFieldViewModel.swift
//  Kratos
//
//  Created by Dylan Straughan on 4/21/18.
//  Copyright © 2018 Dylan Straughan. All rights reserved.
//

import Foundation
import RxSwift

final class TextFieldViewModel {
    
    // MARK: - properties -
    let disposeBag = DisposeBag()
    let input = Variable<String>("")
    let isValid = ReplaySubject<Bool>.create(bufferSize: 1)
    
    let type: TextFieldType
    
    // MARK: - initialization -
    init(type: TextFieldType) {
        self.type = type
        
        bind()
    }
}

extension TextFieldViewModel: RxBinder {
    func bind() {
        input
            .asObservable()
            .map { [unowned self] in self.type.validation($0) }
            .bind(to: isValid)
            .disposed(by: disposeBag)
    }
}


