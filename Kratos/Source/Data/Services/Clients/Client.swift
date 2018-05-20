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
    
    private static var shared: Client?
    
    let reachabilityManager = NetworkReachabilityManager()
    
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
    
    var userLoadStatus = Variable<LoadStatus>(.none)
    var _user = Variable<User?>(nil)
    
    var _isLoggedIn = Variable<Bool>(false)
    
    let microStore = MicroStore()
    
    fileprivate var ongoingRequests = [String: Observable<Data>]()
    
    fileprivate(set) var kratosClient: KratosClient
    
    let disposeBag = DisposeBag()
    
    static func launch(with kratosClient: KratosClient) {
        shared = Client(kratosClient: kratosClient)
    }
    
    private init(kratosClient: KratosClient) {
        self.kratosClient = kratosClient
        _isLoggedIn.value = kratosClient.token != nil
    }
    
    func update(token: String) {
        kratosClient = KratosClient(token: token)
        _isLoggedIn.value = true
    }
    
    func tearDown() {
        invalidateCache()
        kratosClient = KratosClient(token: nil)
        Analytics.setUserProperty("--", forName: "State")
        Analytics.setUserProperty("--", forName: "District")
        _isLoggedIn.value = false
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
        let request = observable.do(
                onNext: { [unowned self] in
                    self.cache.setObject($0 as NSData, forKey: key, expires: .seconds(Client.cacheExpiration))
                },
                onError: { [unowned self] _ in
                    self.ongoingRequests[key] = nil
                },
                onCompleted: { [unowned self] in
                    self.ongoingRequests[key] = nil
                }
            )
            .observeOn(MainScheduler.instance)
            .share(replay: 1)
        
        ongoingRequests[key] = request
        return request
    }
}

extension Client {
    static func provider<T>() -> T {
        return shared as! T
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

extension Client {
    static func setupMessaging() {
        UNUserNotificationCenter.current().delegate = shared
        Messaging.messaging().delegate = shared
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

extension Client : MessagingDelegate {
    // Receive data message on iOS 10 devices.
    func application(received remoteMessage: MessagingRemoteMessage) {
        print("%@", remoteMessage.appData)
    }
    
    func tokenRefreshNotification(_ notification: Notification) {
        if let refreshedToken = InstanceID.instanceID().token(),
           let user = _user.value {
            updateUser(user: user, fcmToken: refreshedToken)
        }
        
        // Connect to FCM since connection may have failed when attempted before having a token.
        connectToFcm()
    }
    
    func connectToFcm() {
        Messaging.messaging().shouldEstablishDirectChannel = true
    }
}
