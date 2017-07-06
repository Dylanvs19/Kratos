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
    
    let disposeBag = DisposeBag()
    let state = Variable<ExpandableTextFieldView.State>(.contracted)
    let title = Variable<String>("")
    let text = Variable<String>("")
    let buttonTitle = Variable<String>("")
    
    let expandedButtonTitle: String
    let contractedButtonTitle: String
    
    init(with title: String?, text: String, expandedTitle: String? = nil, contractedTitle: String? = nil) {
        self.expandedButtonTitle = expandedTitle ?? ""
        self.contractedButtonTitle = contractedTitle ?? ""
        self.title.value = title ?? ""
        self.text.value = text
        
        state.asObservable()
            .map { $0 == .contracted ? self.contractedButtonTitle : self.expandedButtonTitle }
            .bind(to: buttonTitle)
            .disposed(by: disposeBag)
    }
}
