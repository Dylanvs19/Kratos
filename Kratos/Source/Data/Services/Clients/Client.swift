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
import Alamofire

class Client {
    
    let reachabilityManager = NetworkReachabilityManager()
    
    static var `default`: Client {
        return Client(kratosClient: KratosClient(token: nil))
    }
    
    fileprivate static let cacheExpiration: TimeInterval = {
        return Configuration.cacheExpiration
    }()
    
    fileprivate let cache: Cache<NSData> = {
        do {
            return try Cache(name: "Kratos")
        } catch {
            fatalError("Unable to create cache")
        }
    }()
    
    var isLoggedIn = Variable<Bool>(false)
    
    fileprivate var ongoingRequests = [String: Observable<Data>]()
    
    fileprivate(set) var kratosClient: KratosClient
    
    fileprivate let disposeBag = DisposeBag()
    
    init(kratosClient: KratosClient) {
        self.kratosClient = kratosClient
        self.isLoggedIn.value = kratosClient.token != nil
    }
    
    func update(token: String) {
        self.kratosClient = KratosClient(token: token)
        self.isLoggedIn.value = kratosClient.token != nil
    }
    
    func tearDown() {
        invalidateCache()
        kratosClient = KratosClient(token: nil)
        self.isLoggedIn.value = false
    }
}

extension Client {
    // MARK: Requests
    func request(_ target: KratosTarget,
                 ignoreCache: Bool = false) -> Observable<Data> {
        return request(target,
                       microClient: kratosClient,
                       ignoreCache: ignoreCache)
               .handleAuthError(from: self)
    }
    
    func request<M: MicroClient>(_ target: M.T,
                 microClient: M,
                 ignoreCache: Bool = false) -> Observable<Data> {
        return request(key: "\(target)",
                       observable: microClient.buildRequest(target),
                       ignoreCache: ignoreCache)
    }
    
    func request(key: String,
                 observable: Observable<Data>,
                 ignoreCache: Bool) -> Observable<Data> {
        if !ignoreCache,
            let cached = cache.object(forKey: key, returnExpiredObjectIfPresent: !(reachabilityManager?.isReachable ?? true)) {
            //Cache if available and not ignored. Return cached response
            return Observable.just(cached as Data)
            .observeOn(MainScheduler.instance)
        } else if let request = ongoingRequests[key] {
            // Request is ongoing. return associated observable.
            return request
        }
        
        //Generate request and mark it as ongoing
        let request = observable.do(onNext: { [unowned self] in
            self.cache.setObject($0 as NSData, forKey: key, expires: .seconds(Client.cacheExpiration))
        }, onError: { [unowned self] _ in
            self.ongoingRequests[key] = nil
        }, onCompleted: { [unowned self] in
            self.ongoingRequests[key] = nil
        })
        .observeOn(MainScheduler.instance)
        .shareReplay(1)
        
        ongoingRequests[key] = request
        return request
    }
}

extension Client {
    func invalidateCache(for target: KratosTarget) {
        cache.removeObject(forKey: "\(target)")
    }
    
    func invalidateCache() {
        cache.removeAllObjects()
        Store.remove("token")
    }
}

//extension Client: AppClient {}
