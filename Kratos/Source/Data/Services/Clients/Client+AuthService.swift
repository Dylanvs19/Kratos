//
//  Client+AccountService.swift
//  Kratos
//
//  Created by Dylan Straughan on 5/7/17.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import FirebaseMessaging
import FirebaseAnalytics

enum AuthenticationError: Error {
    case notLoggedIn
    case invalidToken
}

extension Client: AuthService {
    var isLoggedIn: ControlEvent<Bool> {
        get {
            return ControlEvent(events: _isLoggedIn.asObservable())
        }
    }
    
    func register(user: User, fcmToken: String?) -> Observable<Bool> {
        return request(.register(user: user, fcmToken: fcmToken), ignoreCache: true)
            .toJson()
            .map { _ in return true }
    }
    
    func confirm(pin: String) -> Observable<Bool> {
        return request(.confirmation(pin: pin), ignoreCache: true)
            .toJson()
            .map { _ in return true }
    }
    
    func login(email: String, password: String) -> Observable<Void> {
        return request(.login(email: email, password: password), ignoreCache: true)
            .toJson()
            .map { jsonObject -> String in
                guard let json = jsonObject as? [String: Any],
                      let token = json["token"] as? String else {
                    throw KratosError.mappingError(type: .unexpectedValue)
                }
                return token
            }
            .do(onNext: { [unowned self] token in
                self.update(token: token)
                Store.shelve(token, key: "token")
            })
            .map { _ in return () }
    }
    
    func forgotPassword(email: String) -> Observable<Bool> {
        return request(.forgotPassword(email: email))
            .toJson()
            .map {
                guard let boolDict = $0 as? [String: Bool],
                      let bool = boolDict["ok"] else {
                    throw KratosError.mappingError(type: .unexpectedValue)
                }
            return bool
        }
    }
    
    func resentConfirmation(email: String) -> Observable<Void> {
        return request(.resendConfirmation(email: email))
            .map { _ in return () }
    }
    
    func fetchUser() {
        guard kratosClient.token != nil else {
            userLoadStatus.value = .error(KratosError.authError(error: .notLoggedIn))
            return
        }
        
        request(.fetchUser)
            .toJson()
            .mapObject(type: User.self)
            .subscribe(
                onNext: { [weak self] user in
                    guard let `self` = self else { return }
                    Analytics.setUserProperty("\(user.address.state)", forName: "State")
                    Analytics.setUserProperty("\(user.district)", forName: "District")
                    self._user.value = user
                },
                onError: { [weak self] error in
                    guard let `self` = self else { return }
                    self.userLoadStatus.value = .error(error)
                }
            )
            .disposed(by: disposeBag)
    }
    
    func updateUser(user: User, fcmToken: String?) {
        guard kratosClient.token != nil else {
            userLoadStatus.value = .error(KratosError.authError(error: .notLoggedIn))
            return
        }
        
        request(.update(user: user, fcmToken: fcmToken))
            .toJson()
            .mapObject(type: User.self)
            .subscribe(
                onNext: { [weak self] user in
                    guard let `self` = self else { return }
                    Analytics.setUserProperty("\(user.address.state)", forName: "State")
                    Analytics.setUserProperty("\(user.district)", forName: "District")
                    self._user.value = user
                },
                onError: { [weak self] error in
                    guard let `self` = self else { return }
                    self.userLoadStatus.value = .error(error)
                }
            )
            .disposed(by: disposeBag)
    }
    
    func logOut() {
        tearDown()
    }
}
