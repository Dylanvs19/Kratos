//
//  APIClient.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/31/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import Foundation

struct APIClient {
    
    static func register(user: User, with password: String, success: (User) -> (), failure: (NSError?) -> ()) {
        
        // URL Components
        guard let url = NSURL(string: Constants.REGISTRATION_URL) else {
            fatalError()
        }
        let session: NSURLSession = NSURLSession.sharedSession()
        let request = NSMutableURLRequest()
        
        if let dict = user.toJson(with: password) {
            do {
                try request.setAuthentication(url, requestType: .post, body: dict)
            } catch let error as NSError {
                failure(error)
            }
            
            let task: NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
                if let data = data {
                    do {
                        let obj = try NSJSONSerialization.JSONObjectWithData(data, options: [])
                        if let obj = obj as? [String: AnyObject],
                            let user = User(json: obj) {
                            dispatch_async(dispatch_get_main_queue(), {
                                success(user)
                            })
                        }
                        if let httpResponse = response as? NSHTTPURLResponse {
                            debugPrint("status code: \(httpResponse.statusCode)")
                        }
                    } catch let error as NSError {
                        failure(error)
                    }
                }
                if error != nil {
                    failure(error)
                }
            })
            task.resume()
        }
    }
    
    static func fetchUser(success: User -> (), failure: (NSError?) -> ()) {
        // URL Components
        guard let url = NSURL(string: Constants.USER_URL) else {
            fatalError()
        }
        
            let session: NSURLSession = NSURLSession.sharedSession()
            let request = NSMutableURLRequest()
            do {
                try request.setAuthentication(url, requestType: .get, body: nil)
            } catch let error as NSError {
                failure(error)
            }
            
            let task: NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
                if let data = data {
                    do {
                        let obj = try NSJSONSerialization.JSONObjectWithData(data, options: [])
                        if let obj = obj as? [String: AnyObject],
                            let user = User(json: obj, pureUser: true) {
                            dispatch_async(dispatch_get_main_queue(), {
                                success(user)
                            })
                        }
                        if let httpResponse = response as? NSHTTPURLResponse {
                            debugPrint("status code: \(httpResponse.statusCode)")
                        }
                    } catch let error as NSError {
                        failure(error)
                    }
                }
                if error != nil {
                    failure(error)
                }
            })
            task.resume()
    }
    
    static func logIn(with phone: Int, password: String, success: (User) -> (), failure: (NSError?) -> ()) {
        let dict = ["session": [
            "phone": phone,
            "password": password
            ]]
        
        let session: NSURLSession = NSURLSession.sharedSession()
        guard let url = NSURL(string: Constants.LOGIN_URL) else {
            fatalError()
        }
        let request = NSMutableURLRequest()
        
        do {
            try request.setAuthentication(url, requestType: .post, body: dict)
        } catch let error as NSError {
            failure(error)
        }
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
            if let data = data {
                do {
                    let obj = try NSJSONSerialization.JSONObjectWithData(data, options: [])
                    if let obj = obj as? [String: AnyObject],
                        let user = User(json: obj) {
                        dispatch_async(dispatch_get_main_queue(), {
                            success(user)
                        })
                    }
                    if let httpResponse = response as? NSHTTPURLResponse {
                        debugPrint("status code: \(httpResponse.statusCode)")
                    }
                } catch let error as NSError {
                    failure(error)
                }
            }
            if error != nil {
                failure(error)
            }
        })
        task.resume()
    }
    
    static func loadRepresentatives(for state: String, and district: Int, success: ([Representative]) -> (), failure: (NSError?) -> ()) {
        
        let session: NSURLSession = NSURLSession.sharedSession()
        guard let url = NSURL(string: "\(Constants.REPRESENTATIVES_URL)\(state)/\(district)") else {
            fatalError()
        }
        let request = NSMutableURLRequest()
        
        do {
            try request.setAuthentication(url, requestType: .get, body: nil)
        } catch let error as NSError {
            failure(error)
        }
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
            if let data = data {
                do {
                    let obj = try NSJSONSerialization.JSONObjectWithData(data, options: [])
                    if let obj = obj as? [[String: AnyObject]] {
                        let reps = obj.map { return Representative(json: $0) }
                        dispatch_async(dispatch_get_main_queue(), {
                            success(reps)
                        })
                    }
                    if let httpResponse = response as? NSHTTPURLResponse {
                        print("status code: \(httpResponse.statusCode)")
                    }
                } catch let error as NSError {
                    failure(error)
                }
            }
            if error != nil {
                failure(error)
            }
        })
        task.resume()
    }
    
    static func loadBill(from billId: String, success: (Bill) -> (Void), failure: (NSError?) -> (Void)) {
        
        guard let url = NSURL(string: "\(Constants.BILL_URL)\(billId)") else {
            failure(nil)
            return
        }
        let session: NSURLSession = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: url)
        
        do {
            try request.setAuthentication(url, requestType: .get, body: nil)
        } catch let error as NSError {
            failure(error)
        }
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
            if let data = data {
                do {
                    let obj = try NSJSONSerialization.JSONObjectWithData(data, options: [])
                    if let obj = obj as? [String: AnyObject],
                        let bill = Bill(json: obj) {
                        dispatch_async(dispatch_get_main_queue(), {
                            success(bill)
                        })
                    }
                    if let httpResponse = response as? NSHTTPURLResponse {
                        print("status code: \(httpResponse.statusCode)")
                    }
                } catch let error as NSError {
                    failure(error)
                }
            }
            if error != nil {
                failure(error)
            }
        })
        task.resume()
    }
    
    static func loadVotes(for representative: Representative, success: ([Vote]) -> (Void), failure: (NSError?) -> (Void)) {
        
        guard let id = representative.id,
            let url = NSURL(string: "\(Constants.VOTES_URL)\(id)/votes") else {
                failure(nil)
                return
        }
        
        let session: NSURLSession = NSURLSession.sharedSession()
        let request = NSMutableURLRequest()
        
        do {
            try request.setAuthentication(url, requestType: .get, body: nil)
        } catch let error as NSError {
            failure(error)
        }
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
            if let data = data {
                do {
                    let obj = try NSJSONSerialization.JSONObjectWithData(data, options: [])
                    if let obj = obj as? [[String: AnyObject]] {
                        let votes = obj.map({
                            Vote(json: $0)
                        })
                        dispatch_async(dispatch_get_main_queue(), {
                            success(votes)
                        })
                    }
                    if let httpResponse = response as? NSHTTPURLResponse {
                        print("status code: \(httpResponse.statusCode)")
                    }
                } catch let error as NSError {
                    failure(error)
                }
            }
            if error != nil {
                failure(error)
            }
        })
        task.resume()
    }
    
}
