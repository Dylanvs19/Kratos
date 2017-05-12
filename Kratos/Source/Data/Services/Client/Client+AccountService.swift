//
//  Client+AccountService.swift
//  Kratos
//
//  Created by Dylan Straughan on 5/7/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import RxSwift

extension Client: AccountService {
    
    func register(user: User, password: String) -> Observable<User> {
        return request(.register(user: user, password: password), forceRefresh: true)
            .toJson()
            .mapObject()
    }
    
    func login(email: String, password: String) -> Observable<(String, User)> {
        return request(.logIn(email: email, password: password), forceRefresh: true)
            .toJson()
            .map {
                guard let json = $0 as? [String: Any] else {
                    throw KratosError.mappingError(type: .unexpectedValue)
                }
                guard let token = json["token"] as? String else {
                    throw KratosError.mappingError(type: .unexpectedValue)
                }
                guard let userDict = json["user"] as? [String: Any],
                      let user = User(json: userDict) else {
                    throw KratosError.mappingError(type: .unexpectedValue)
                }
                return (token, user)
        }
        
    }
    
    func forgotPassword(email: String) -> Observable<Bool> {
        return request(.forgotPassword(email: email), forceRefresh: true)
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
        return request(.resendConfirmation(email: email), forceRefresh: true)
            .map { _ in return () }
    }
    
    func fetchUser() -> Observable<User> {
        return request(.fetchUser)
            .toJson()
            .mapObject()
    }
    
    func updateUser(user: User) -> Observable<User> {
        return request(.update(user: user), forceRefresh: true)
            .toJson()
            .mapObject()
    }
}
