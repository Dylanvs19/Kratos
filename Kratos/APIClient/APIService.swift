//
//  APIService.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/31/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import Foundation

struct APIService {
    
    static func register(_ user: User, with password: String, success: @escaping (User) -> (), failure: @escaping (NetworkError) -> ()) {
        
        // URL Components
        guard let url = URL(string: Constants.REGISTRATION_URL) else {
            failure(.invalidURL)
            return
        }
        let session: URLSession = URLSession.shared
        if let dict = user.toJson(with: password) {
            
            let request = NSMutableURLRequest()
            do {
                try request.setAuthentication(for: url, requestType: .post, body: dict as [String : AnyObject])
            } catch {
                failure(.invalidSerialization)
            }
            
            let task: URLSessionDataTask = session.dataTask(with: request as URLRequest) { (data, response, error) in
                guard let data = data else {
                    failure(.nilData)
                    return
                }
                var obj:[String: AnyObject]?
                do {
                    obj = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject]
                } catch {
                    failure(.invalidSerialization)
                }
                if let obj = obj,
                    let user = User(json: obj) {
                    DispatchQueue.main.async(execute: {
                        success(user)
                    })
                }
                if let httpResponse = response as? HTTPURLResponse {
                    if let error = NetworkError.error(for: httpResponse.statusCode) {
                        failure(error)
                    }
                }
            }
            task.resume()
        }
    }
    
    static func fetchUser(_ success: @escaping (User) -> (), failure: @escaping (NetworkError?) -> ()) {
        // URL Components
        guard let url = URL(string: Constants.USER_URL) else {
            failure(.invalidURL)
            return
        }
        
        let session: URLSession = URLSession.shared
        let request = NSMutableURLRequest()
        do {
            try request.setAuthentication(for: url, requestType: .get, body: nil)
        } catch {
            failure(.invalidSerialization)
        }
        
        let task: URLSessionDataTask = session.dataTask(with: request as URLRequest) { (data, response, error) in
            if let data = data {
                
                var obj:[String: AnyObject]?
                do {
                    obj = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject]
                } catch {
                    failure(.invalidSerialization)
                }
                
                if let obj = obj,
                   let user = User(json: obj, pureUser: true) {
                    DispatchQueue.main.async(execute: {
                        success(user)
                    })
                }
            }
            if let httpResponse = response as? HTTPURLResponse {
                if let error = NetworkError.error(for: httpResponse.statusCode) {
                    failure(error)
                }
            }
        }
        task.resume()
    }
    
    static func logIn(with phone: Int, password: String, success: @escaping (User) -> (), failure: @escaping (NetworkError) -> ()) {
        let dict: [String: [String: Any]] = ["session": [
            "phone": phone,
            "password": password
            ]]
        
        let session: URLSession = URLSession.shared
        guard let url = URL(string: Constants.LOGIN_URL) else {
            failure(.invalidURL)
            return
        }
        let request = NSMutableURLRequest()
        
        do {
            try request.setAuthentication(for: url, requestType: .post, body: dict as [String : AnyObject])
        } catch {
            failure(.invalidSerialization)
        }
        
        let task: URLSessionDataTask = session.dataTask(with: request as URLRequest) { (data, response, error) in
            if let data = data {
                var obj:[String: AnyObject]?
                do {
                    obj = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject]
                } catch {
                    failure(.invalidSerialization)
                }
                if let obj = obj,
                    let user = User(json: obj) {
                    DispatchQueue.main.async(execute: {
                        success(user)
                    })
                }
            }
            if let httpResponse = response as? HTTPURLResponse {
                if let error = NetworkError.error(for: httpResponse.statusCode) {
                    failure(error)
                }
            }
            
        }
        task.resume()
    }
    
    static func loadRepresentatives(for state: String, and district: Int, success: @escaping ([Person]) -> (), failure: @escaping (NetworkError) -> ()) {
        
        let session: URLSession = URLSession.shared
        guard let url = URL(string: "\(Constants.REPRESENTATIVES_URL)\(state)/\(district)") else {
            failure(.invalidURL)
            return
        }
        
        let request = NSMutableURLRequest()
        do {
            try request.setAuthentication(for: url, requestType: .get, body: nil)
        } catch {
            failure(.invalidSerialization)
        }
        
        let task: URLSessionDataTask = session.dataTask(with: request as URLRequest) { (data, response, error) in
            if let data = data {
                
                var obj:[String: AnyObject]?
                do {
                    obj = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject]
                } catch {
                    failure(.invalidSerialization)
                }
                
                if let repArray = obj?["data"] as? [[String: AnyObject]] {
                    let reps = repArray.map({ (dictionary) -> Person? in
                        return Person(json: dictionary)
                    }).flatMap({ $0 })
                    
                    DispatchQueue.main.async(execute: {
                        success(reps)
                    })
                }
            }
            if let httpResponse = response as? HTTPURLResponse {
                if let error = NetworkError.error(for: httpResponse.statusCode) {
                    failure(error)
                }
            }
        }
        task.resume()
    }
    
    
    
    static func loadBill(from billId: Int, success: @escaping (Bill) -> (Void), failure: @escaping (NetworkError) -> (Void)) {
        
        guard let url = URL(string: "\(Constants.BILL_URL)\(billId)") else {
            failure(.invalidURL)
            return
        }
        let session: URLSession = URLSession.shared
        let request = NSMutableURLRequest()
        do {
            try request.setAuthentication(for: url, requestType: .get, body: nil)
        } catch {
            failure(.invalidSerialization)
        }
        
        let task: URLSessionDataTask = session.dataTask(with: request as URLRequest) { (data, response, error) in
            if let data = data {
                
                var obj:[String: AnyObject]?
                do {
                    obj = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject]
                } catch {
                    failure(.invalidSerialization)
                }
                
                if let obj = obj,
                    let bill = Bill(json: obj) {
                    DispatchQueue.main.async(execute: {
                        success(bill)
                    })
                }
            }
            if let httpResponse = response as? HTTPURLResponse {
                if let error = NetworkError.error(for: httpResponse.statusCode) {
                    failure(error)
                }
            }
        }
        task.resume()
    }
    
    static func loadVotes(for representative: Person, success: @escaping ([LightTally]) -> (Void), failure: @escaping (NetworkError) -> (Void)) {
        
        guard let id = representative.id,
            let url = URL(string: "\(Constants.VOTES_URL)\(id)/votes") else {
                failure(.invalidURL)
                return
        }
        
        let session: URLSession = URLSession.shared
        let request = NSMutableURLRequest()
        
        do {
            try request.setAuthentication(for: url, requestType: .get, body: nil)
        } catch {
            failure(.invalidSerialization)
        }
        
        let task: URLSessionDataTask = session.dataTask(with: request as URLRequest) { (data, response, error) in
            if let data = data {
                
                var obj:[String: AnyObject]?
                do {
                    obj = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject]
                } catch {
                    failure(.invalidSerialization)
                }
                
                if let tallies = obj?["data"]?["voting_record"] as? [[String:AnyObject]] {
                    let lightTallies = tallies.map({
                        LightTally(json: $0)
                    })
                    DispatchQueue.main.async(execute: {
                        success(lightTallies)
                    })
                }
            }
            if let httpResponse = response as? HTTPURLResponse {
                if let error = NetworkError.error(for: httpResponse.statusCode) {
                    failure(error)
                }
            }
        }
        task.resume()
    }
}
