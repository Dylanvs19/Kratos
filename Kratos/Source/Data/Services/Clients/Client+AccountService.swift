//
//  Client+AccountService.swift
//  Kratos
//
//  Created by Dylan Straughan on 5/7/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import RxSwift

enum AuthenticationError {
    case notLoggedIn
    case invalidToken
}


extension Client: AccountService {
    
    func register(user: User) -> Observable<Bool> {
        return request(.register(user: user), ignoreCache: true)
            .toJson()
            .map { _ in return true }
    }
    
    func login(email: String, password: String) -> Observable<String> {
        return request(.login(email: email, password: password), ignoreCache: true)
            .toJson()
            .map {
                guard let json = $0 as? [String: Any],
                      let token = json["token"] as? String else {
                    throw KratosError.mappingError(type: .unexpectedValue)
                }
                return token
        }
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
        return request(.fetchUser)
            .toJson()
            .mapObject()
    }
    
    func updateUser(user: User) -> Observable<User> {
        return request(.update(user: user))
            .toJson()
            .mapObject()
    }
}