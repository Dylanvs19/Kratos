//
//  KeychainManager.swift
//  Kratos
//
//  Created by Dylan Straughan on 10/13/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import Foundation
import Locksmith

struct KeychainManager {
        
    static func create(_ user: User, success:(Bool) -> ()) {
        guard let token = user.token else {
            success(false)
            return
        }
        let dictionary = ["token": token]
        do {
            try Locksmith.saveData(data: dictionary, forUserAccount: "Kratos")
            success(true)
        } catch {
            success(false)
        }
    }
    
    static func fetchToken() -> String? {
        let dictionary = Locksmith.loadDataForUserAccount(userAccount: "Kratos")
        return dictionary?["token"] as? String
    }
    
    static func update(_ user: User, success:(Bool) -> ()) {
        if fetchToken() == nil {
            create(user, success: { (createSuccess) in
                success(createSuccess)
            })
        } else {
            guard let token = user.token else {
                success(false)
                return
            }
            do {
                try Locksmith.updateData(data: ["token": token], forUserAccount: "Kratos")
                success(true)
            } catch {
                success(false)
            }
        }
    }
    
    static func delete(_ success:(Bool) -> ()) {
        do {
            try Locksmith.deleteDataForUserAccount(userAccount: "Kratos")
            success(true)
        } catch {
            success(false)
        }
    }
}
