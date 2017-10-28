//
//  Observable+JSON.swift
//  Kratos
//
//  Created by Dylan Straughan on 5/9/17.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
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
    
    func handleAuthError(from client: Client) -> Observable<Data> {
        return catchError({ error in
            guard let kratosError = error as? KratosError,
                  case let .requestError(_, _, statusCode) = kratosError,
                  statusCode == 403 else { throw error }
            
            client.tearDown()
            throw error
        })
    }
}
