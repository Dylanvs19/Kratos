//
//  AccountService.swift
//  Kratos
//
//  Created by Dylan Straughan on 5/6/17.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol AuthService: Provider {
    
    func register(user: User, fcmToken: String?) -> Observable<Bool>
    
    func login(email: String, password: String) -> Observable<Void>
    
    func forgotPassword(email: String) -> Observable<Bool>
    
    func resentConfirmation(email: String) -> Observable<Void>
    
    func fetchUser()
    
    func updateUser(user: User, fcmToken: String?)
    
    var isLoggedIn: ControlEvent<Bool> { get }
    
    func logOut() 
}

