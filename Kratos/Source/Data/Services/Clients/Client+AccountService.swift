//
//  Client+AccountService.swift
//  Kratos
//
//  Created by Dylan Straughan on 5/7/17.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//

import Foundation
import RxSwift
import FirebaseMessaging
import FirebaseAnalytics

enum AuthenticationError: Error {
    case notLoggedIn
    case invalidToken
}


extension Client: AccountService {
    
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
            .do(onNext: { [weak self] token in
                self?.update(token: token)
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
    
    func fetchUser() -> Observable<User> {
        guard kratosClient.token != nil else { return Observable.error(KratosError.authError(error: .notLoggedIn)) }
        
        return request(.fetchUser)
            .toJson()
            .mapObject()
            .do(
                onNext: { [weak self] user in
                    guard let `self` = self else { return }
                    FIRAnalytics.setUserPropertyString("\(user.address.state)", forName: "State")
                    FIRAnalytics.setUserPropertyString("\(user.district)", forName: "District")
                    self.user.value = user
                }
            )
    }
    
    func updateUser(user: User, fcmToken: String?) -> Observable<User> {
        guard kratosClient.token != nil else { return Observable.error(KratosError.authError(error: .notLoggedIn)) }
        
        return request(.update(user: user, fcmToken: fcmToken))
            .toJson()
            .mapObject()
            .do(
                onNext: { [weak self] user in
                    guard let `self` = self else { return }
                    FIRAnalytics.setUserPropertyString("\(user.address.state)", forName: "State")
                    FIRAnalytics.setUserPropertyString("\(user.district)", forName: "District")
                    self.user.value = user
                }
            )
    }
}
