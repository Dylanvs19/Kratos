//
//  APIClient.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/31/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import Foundation

struct APIClient {
    
    static func register(_ user: User, with password: String, success: @escaping (User) -> (), failure: @escaping (NSError?) -> ()) {
        
        // URL Components
        guard let url = URL(string: Constants.REGISTRATION_URL) else {
            fatalError()
        }
        let session: URLSession = URLSession.shared
        let request = NSMutableURLRequest()
        
        if let dict = user.toJson(with: password) {
            do {
                try request.setAuthentication(for: url, requestType: .post, body: dict)
            } catch let error as NSError {
                failure(error)
            }
            
            let task: URLSessionDataTask = session.dataTask(with: request as URLRequest) { (data, response, error) in
                if let data = data {
                    do {
                        let obj = try JSONSerialization.jsonObject(with: data, options: [])
                        if let obj = obj as? [String: AnyObject],
                            let user = User(json: obj) {
                            DispatchQueue.main.async(execute: {
                                success(user)
                            })
                        }
                        if let httpResponse = response as? HTTPURLResponse {
                            debugPrint("status code: \(httpResponse.statusCode)")
                        }
                    } catch let error as NSError {
                        failure(error)
                    }
                }
                if error != nil {
                    failure(error as NSError?)
                }
            }
            task.resume()
        }
    }
    
    static func fetchUser(_ success: @escaping (User) -> (), failure: @escaping (NSError?) -> ()) {
        // URL Components
        guard let url = URL(string: Constants.USER_URL) else {
            fatalError()
        }
        
            let session: URLSession = URLSession.shared
            let request = NSMutableURLRequest()
            do {
                try request.setAuthentication(for: url, requestType: .get, body: nil)
            } catch let error as NSError {
                failure(error)
            }
            
            let task: URLSessionDataTask = session.dataTask(with: request as URLRequest) { (data, response, error) in
                if let data = data {
                    do {
                        let obj = try JSONSerialization.jsonObject(with: data, options: [])
                        if let obj = obj as? [String: AnyObject],
                            let user = User(json: obj, pureUser: true) {
                            DispatchQueue.main.async(execute: {
                                success(user)
                            })
                        }
                        if let httpResponse = response as? HTTPURLResponse {
                            debugPrint("status code: \(httpResponse.statusCode)")
                        }
                    } catch let error as NSError {
                        failure(error)
                    }
                }
                if error != nil {
                    failure(error as NSError?)
                }
            }
            task.resume()
    }
    
    static func logIn(with phone: Int, password: String, success: @escaping (User) -> (), failure: @escaping (NSError?) -> ()) {
        let dict: [String: [String: Any]] = ["session": [
            "phone": phone,
            "password": password
            ]]
        
        let session: URLSession = URLSession.shared
        guard let url = URL(string: Constants.LOGIN_URL) else {
            fatalError()
        }
        let request = NSMutableURLRequest()
        
        do {
            try request.setAuthentication(for: url, requestType: .post, body: dict as [String : AnyObject])
        } catch let error as NSError {
            failure(error)
        }
        
        let task: URLSessionDataTask = session.dataTask(with: request as URLRequest) { (data, response, error) in
            if let data = data {
                do {
                    let obj = try JSONSerialization.jsonObject(with: data, options: [])
                    if let obj = obj as? [String: AnyObject],
                        let user = User(json: obj) {
                        DispatchQueue.main.async(execute: {
                            success(user)
                        })
                    }
                    if let httpResponse = response as? HTTPURLResponse {
                        debugPrint("status code: \(httpResponse.statusCode)")
                    }
                } catch let error as NSError {
                    failure(error)
                }
            }
            if error != nil {
                failure(error as NSError?)
            }
        }
        task.resume()
    }
    
    static func loadRepresentatives(for state: String, and district: Int, success: @escaping ([DetailedRepresentative]) -> (), failure: @escaping (NSError?) -> ()) {
        
        let session: URLSession = URLSession.shared
        guard let url = URL(string: "\(Constants.REPRESENTATIVES_URL)\(state)/\(district)") else {
            fatalError()
        }
        let request = NSMutableURLRequest()
        
        do {
            try request.setAuthentication(for: url, requestType: .get, body: nil)
        } catch let error as NSError {
            failure(error)
        }
        
        let task: URLSessionDataTask = session.dataTask(with: request as URLRequest) { (data, response, error) in
            if let data = data {
                do {
                    let obj = try JSONSerialization.jsonObject(with: data, options: [])
                    if let obj = obj as? [[String: AnyObject]] {
                        let reps = obj.map { return DetailedRepresentative(from: $0) }
                        DispatchQueue.main.async(execute: {
                            success(reps)
                        })
                    }
                    if let httpResponse = response as? HTTPURLResponse {
                        print("status code: \(httpResponse.statusCode)")
                    }
                } catch let error as NSError {
                    failure(error)
                }
            }
            if error != nil {
                failure(error as NSError?)
            }
        }
        task.resume()
    }
    
    static func loadBill(from billId: Int, success: @escaping (Bill) -> (Void), failure: @escaping (NSError?) -> (Void)) {
        
        guard let url = URL(string: "\(Constants.BILL_URL)\(billId)") else {
            failure(nil)
            return
        }
        let session: URLSession = URLSession.shared
        let request = NSMutableURLRequest(url: url)
        
        do {
            try request.setAuthentication(for: url, requestType: .get, body: nil)
        } catch let error as NSError {
            failure(error)
        }
        
        let task: URLSessionDataTask = session.dataTask(with: request as URLRequest) { (data, response, error) in
            if let data = data {
                do {
                    let obj = try JSONSerialization.jsonObject(with: data, options: [])
                    if let obj = obj as? [String: AnyObject],
                        let bill = Bill(json: obj) {
                        DispatchQueue.main.async(execute: {
                            success(bill)
                        })
                    }
                    if let httpResponse = response as? HTTPURLResponse {
                        print("status code: \(httpResponse.statusCode)")
                    }
                } catch let error as NSError {
                    failure(error)
                }
            }
            if error != nil {
                failure(error as NSError?)
            }
        }
        task.resume()
    }
    
    static func loadVotes(for representative: Representative, success: @escaping ([Vote]) -> (Void), failure: @escaping (NSError?) -> (Void)) {
        
        guard let id = representative.id,
            let url = URL(string: "\(Constants.VOTES_URL)\(id)/votes") else {
                failure(nil)
                return
        }
        
        let session: URLSession = URLSession.shared
        let request = NSMutableURLRequest()
        
        do {
            try request.setAuthentication(for: url, requestType: .get, body: nil)
        } catch let error as NSError {
            failure(error)
        }
        
        let task: URLSessionDataTask = session.dataTask(with: request as URLRequest) { (data, response, error) in
            if let data = data {
                do {
                    let obj = try JSONSerialization.jsonObject(with: data, options: [])
                    if let obj = obj as? [[String: AnyObject]] {
                        let votes = obj.map({
                            Vote(json: $0)
                        })
                        DispatchQueue.main.async(execute: {
                            success(votes)
                        })
                    }
                    if let httpResponse = response as? HTTPURLResponse {
                        print("status code: \(httpResponse.statusCode)")
                    }
                } catch let error as NSError {
                    failure(error)
                }
            }
            if error != nil {
                failure(error as NSError?)
            }
        }
        task.resume()
    }
}
