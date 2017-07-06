//
//  AccountService.swift
//  Kratos
//
//  Created by Dylan Straughan on 5/6/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import RxSwift

protocol AccountService {
    
    func register(user: User) -> Observable<Bool>
    
    func login(email: String, password: String) -> Observable<String>
    
    func forgotPassword(email: String) -> Observable<Bool>
    
    func resentConfirmation(email: String) -> Observable<Void>
    
    func fetchUser() -> Observable<User>
    
    func updateUser(user: User) -> Observable<User> 
    
}

