//
//  Client.swift
//  Kratos
//
//  Created by Dylan Straughan on 5/7/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import RxSwift
import AwesomeCache

class Client {
    
    public let environment: Environment
    public var baseURL: URL {
        guard let url = URL(string: Environment.production.URL) else {
            fatalError("Base URL not encodable")
        }
        return url
    }
    fileprivate let cache: Cache<NSData>
    fileprivate var ongoingRequests = [String: Observable<Data>]()
    
    init(environment: Environment) {
        self.environment = environment
        do {
            self.cache = try Cache(name: "Kratos")
        } catch {
            fatalError("could not initialize cache")
        }
    }
    
    fileprivate func request(_ key: String, observable: Observable<Data>, forceRefresh: Bool, omitFromCache: Bool  = false) -> Observable<Data> {
        if let object = cache.object(forKey: key, returnExpiredObjectIfPresent: true),
                        !forceRefresh,
                        !omitFromCache {
            return Observable.just(object as Data)
        } else if let request = ongoingRequests[key] {
            return request
        }
        
        let request = observable.do(
            onNext: {
                if !omitFromCache {
                    self.cache.setObject(($0 as NSData), forKey: key, expires: .seconds(300))
                }
            },
            onError: { [unowned self] value in
                self.ongoingRequests[key] = nil
            },
            onCompleted: { [unowned self] value in
                self.ongoingRequests[key] = nil
            })
        .observeOn(MainScheduler.instance)
        .shareReplay(1)
        
        ongoingRequests[key] = request
        return request
    }
    
    //Make requests for KratosTarget.
    func request(_ target: KratosTarget, forceRefresh: Bool = false, omitFromCache: Bool = false) -> Observable<Data> {
        return request("\(target)",
                observable: URLSession.shared.rx.send(client: self, target: target),
                forceRefresh: forceRefresh,
                omitFromCache: omitFromCache)
    }
}
