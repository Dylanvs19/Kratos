//
//  Client.swift
//  Kratos
//
//  Created by Dylan Straughan on 5/7/17.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//

import Foundation
import RxSwift
import AwesomeCache
import Alamofire
import Firebase
import FirebaseMessaging
import FirebaseAnalytics
import UserNotifications

class Client: NSObject {
    
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
    
    var user = Variable<User?>(nil)
    
    let microStore = MicroStore()
    
    fileprivate var ongoingRequests = [String: Observable<Data>]()
    
    fileprivate(set) var kratosClient: KratosClient
    
    let disposeBag = DisposeBag()
    
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
        FIRAnalytics.setUserPropertyString("--", forName: "State")
        FIRAnalytics.setUserPropertyString("--", forName: "District")
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

@available(iOS 10, *)
extension Client : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        // Print message ID.
        print("Message ID: \(userInfo["gcm.message_id"]!)")
        
        // Print full message.
        print("%@", userInfo)
        
    }
}

extension Client : FIRMessagingDelegate {
    // Receive data message on iOS 10 devices.
    func applicationReceivedRemoteMessage(_ remoteMessage: FIRMessagingRemoteMessage) {
        print("%@", remoteMessage.appData)
    }
    
    func tokenRefreshNotification(_ notification: Notification) {
        if let refreshedToken = FIRInstanceID.instanceID().token(),
           let user = user.value {
            updateUser(user: user, fcmToken: refreshedToken)
                .bind(to: self.user)
                .disposed(by: disposeBag)
        }
        
        // Connect to FCM since connection may have failed when attempted before having a token.
        connectToFcm()
    }
    
    func connectToFcm() {
        FIRMessaging.messaging().connect { (error) in
            if (error != nil) {
                print("Unable to connect with FCM. \(String(describing: error))")
            } else {
                print("Connected to FCM.")
            }
        }
    }
}

//extension Client: AppClient {}
