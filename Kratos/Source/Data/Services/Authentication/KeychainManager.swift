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
    
    static var token: String? {
        let dictionary = Locksmith.loadDataForUserAccount(userAccount: "Kratos")
        return dictionary?["token"] as? String
    }
    
    static func create(_ token: String) -> Bool {
        let dictionary = ["token": token]
        do {
            try Locksmith.saveData(data: dictionary, forUserAccount: "Kratos")
            return true
        } catch {
            //Retry with update token
            return update(token)
        }
    }
    
    static func update(_ token: String) -> Bool {
        do {
            try Locksmith.updateData(data: ["token": token], forUserAccount: "Kratos")
            return true
        } catch {
            //Retry to create token
            return create(token)
        }
    }
    
    static func delete() -> Bool {
        do {
            try Locksmith.deleteDataForUserAccount(userAccount: "Kratos")
            return true
        } catch {
            return false
        }
    }
}
