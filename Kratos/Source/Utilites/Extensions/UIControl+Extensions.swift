//
//  UIControl+Extensions.swift
//  Kratos
//
//  Created by Dylan Straughan on 12/16/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension Reactive where Base: UIControl {
    
    public var isEditing: ControlEvent<Bool> {
        let source: Observable<Bool> = Observable.deferred{ [weak control = self.base] in
            guard let control = control else { return Observable.just(false) }
            
            return Observable.combineLatest(control.rx.controlEvent(.editingDidBegin).scan(0) { (count, _) in count + 1},
                                            control.rx.controlEvent(.editingDidEnd).scan(0) { (count, _) in count + 1}.startWith(0))
                .map { $0 > $1 }
        }
        
        return ControlEvent(events: source)
    }
}
