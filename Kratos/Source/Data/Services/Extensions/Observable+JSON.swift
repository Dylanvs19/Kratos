//
//  Observable+JSON.swift
//  Kratos
//
//  Created by Dylan Straughan on 5/9/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import RxSwift

extension ObservableType where E == Data {
    
    func toJson() -> Observable<Any> {
        return observeOn(SerialDispatchQueueScheduler(qos: .background))
            .flatMap { data -> Observable<Any> in
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                return Observable.just(json)
        }
        .observeOn(MainScheduler.instance)
    }
}
