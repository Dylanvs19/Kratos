//
//  APIClient.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/31/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import Foundation

struct APIClient {
    
    static func register(user: User, with password: String, success: ([String: [String: AnyObject]]) -> (Void), failure: (NSError?) -> (Void)) {
        
        let session: NSURLSession = NSURLSession.sharedSession()
        let url = NSURL(string: Constants.REGISTRATION_URL)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let dict = user.toJson(with: password) {
            do {
                let jsonData = try NSJSONSerialization.dataWithJSONObject(dict, options: [])
                request.HTTPBody = jsonData
                
                let task: NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
                    if let data = data {
                        do {
                            let obj = try NSJSONSerialization.JSONObjectWithData(data, options: [])
                            if let obj = obj as? [String: [String: AnyObject]] {
                                dispatch_async(dispatch_get_main_queue(), {
                                    success(obj)
                                })
                            }
                            //                            if let httpResponse = response as? NSHTTPURLResponse {
                            //                                debugPrint("status code: \(httpResponse.statusCode)")
                            //                            }
                        } catch let error as NSError {
                            failure(error)
                        }
                    }
                    if error != nil {
                        failure(error)
                    }
                })
                task.resume()
            } catch let error as NSError {
                failure(error)
            }
        }
    }
    
    static func logIn(with phone: Int, password: String, success: ([String: [String: AnyObject]]) -> (Void), failure: (NSError?) -> (Void)) {
        let dict = ["session": [
            "phone": phone,
            "password": password
            ]]
        
        let session: NSURLSession = NSURLSession.sharedSession()
        let url = NSURL(string: Constants.LOGIN_URL)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(dict, options: [])
            request.HTTPBody = jsonData
            
            let task: NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
                if let data = data {
                    do {
                        let obj = try NSJSONSerialization.JSONObjectWithData(data, options: [])
                        if let obj = obj as? [String: [String: AnyObject]] {
                            dispatch_async(dispatch_get_main_queue(), {
                                success(obj)
                            })
                        }
                        //                            if let httpResponse = response as? NSHTTPURLResponse {
                        //                                debugPrint("status code: \(httpResponse.statusCode)")
                        //                            }
                    } catch let error as NSError {
                        failure(error)
                    }
                }
                if error != nil {
                    failure(error)
                }
            })
            task.resume()
        } catch let error as NSError {
            failure(error)
        }
    }
    
    static func loadRepresentatives(user: User, with password: String, success: ([String: [String: AnyObject]]) -> (Void), failure: (NSError?) -> (Void)) {
        
        let session: NSURLSession = NSURLSession.sharedSession()
        let url = NSURL(string: Constants.ADDRESS_API_CONSTANT)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let dict = user.toJson(with: password) {
            do {
                let jsonData = try NSJSONSerialization.dataWithJSONObject(dict, options: [])
                request.HTTPBody = jsonData
                
                let task: NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
                    if let data = data {
                        do {
                            let obj = try NSJSONSerialization.JSONObjectWithData(data, options: [])
                            if let obj = obj as? [String: [String: AnyObject]] {
                                dispatch_async(dispatch_get_main_queue(), {
                                    success(obj)
                                })
                            }
                            //                            if let httpResponse = response as? NSHTTPURLResponse {
                            //                                debugPrint("status code: \(httpResponse.statusCode)")
                            //                            }
                        } catch let error as NSError {
                            failure(error)
                        }
                    }
                    if error != nil {
                        failure(error)
                    }
                })
                task.resume()
            } catch let error as NSError {
                failure(error)
            }
        }
    }
    
    static func loadBill(from billId: String, success: ([Vote]) -> (Void), failure: (NSError?) -> (Void)) {
        let session: NSURLSession = NSURLSession.sharedSession()
        
        guard let url = NSURL(string: "\(Constants.BILL_URL)\(billId)") else {
                failure(nil)
                return
        }
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        
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
    
    static func loadVotes(for representative: Representative, success: ([Vote]) -> (Void), failure: (NSError?) -> (Void)) {
        
        let session: NSURLSession = NSURLSession.sharedSession()
        
        guard let id = representative.id,
            let url = NSURL(string: "\(Constants.REPRESENTATIVE_URL)\(id)/votes") else {
                failure(nil)
                return
        }
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        
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