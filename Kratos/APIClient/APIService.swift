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
        if let dict = user.toJson(with: password) {
            
            let session: URLSession = URLSession.shared
            let request = URLRequest(url: url, requestType: .post, body: dict)
    
            let task: URLSessionDataTask = session.dataTask(with: request) { (data, response, error) in
                if let httpResponse = response as? HTTPURLResponse {
                    if let error = NetworkError.error(for: httpResponse.statusCode) {
                        failure(error)
                    }
                }
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
            }
            task.resume()
        }
    }
    
    static func fetchUser(_ success: @escaping (User) -> (), failure: @escaping (NetworkError) -> ()) {
        // URL Components
        guard let url = URL(string: Constants.USER_URL) else {
            failure(.invalidURL)
            return
        }
        
        let session: URLSession = URLSession.shared
        let request = URLRequest(url: url, requestType: .get)
        
        let task: URLSessionDataTask = session.dataTask(with: request) { (data, response, error) in
            
            if let httpResponse = response as? HTTPURLResponse {
                if let error = NetworkError.error(for: httpResponse.statusCode) {
                    failure(error)
                }
            }
            
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
        }
        task.resume()
    }
    
    static func logIn(with phone: Int, password: String, success: @escaping (User) -> (), failure: @escaping (NetworkError) -> ()) {
        let parameters: [String: AnyObject] = [
            "phone": phone as AnyObject,
            "password": password as AnyObject
        ]
                
        let dict: [String: Any] = ["session": parameters as Any]
        
        guard let url = URL(string: Constants.LOGIN_URL) else {
            failure(.invalidURL)
            return
        }
        
        let session: URLSession = URLSession.shared
        let request = URLRequest(url: url, requestType: .post, body: dict)
        
        let task: URLSessionDataTask = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            if let httpResponse = response as? HTTPURLResponse {
                if let error = NetworkError.error(for: httpResponse.statusCode) {
                    failure(error)
                }
            }

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
        }
        task.resume()
    }
    
    static func update(with user: User, success: @escaping (User) -> (), failure: @escaping (NetworkError) -> ()) {
        
        if let dict = user.toJsonForUpdate() {
            
            guard let url = URL(string: Constants.USER_URL) else {
                failure(.invalidURL)
                return
            }
            
            let session: URLSession = URLSession.shared
            let request = URLRequest(url: url, requestType: .post, body: dict)
            
            let task: URLSessionDataTask = session.dataTask(with: request as URLRequest) { (data, response, error) in
                
                if let httpResponse = response as? HTTPURLResponse {
                    if let error = NetworkError.error(for: httpResponse.statusCode) {
                        failure(error)
                    }
                }
                
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
            }
            task.resume()
        }
    }
    
    
    
    static func fetchRepresentatives(for state: String, and district: Int, success: @escaping ([Person]) -> (), failure: @escaping (NetworkError) -> ()) {
        
        guard let url = URL(string: "\(Constants.REPRESENTATIVES_URL)\(state)/\(district)") else {
            failure(.invalidURL)
            return
        }
        
        let session: URLSession = URLSession.shared
        let request = URLRequest(url: url, requestType: .get)
        
        let task: URLSessionDataTask = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            if let httpResponse = response as? HTTPURLResponse {
                if let error = NetworkError.error(for: httpResponse.statusCode) {
                    failure(error)
                }
            }
            
            if let data = data {
                var obj:[String: AnyObject]?
                do {
                    obj = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject]
                } catch {
                    failure(.invalidSerialization)
                }
                
                if let repArray = obj?["data"] as? [[String: AnyObject]] {
                    let reps = repArray.map({ (dictionary) -> Person? in
                        return Person(from: dictionary)
                    }).flatMap({ $0 })
                    
                    DispatchQueue.main.async(execute: {
                        success(reps)
                    })
                }
            }
        }
        task.resume()
    }
    
    static func fetchTallies(for representative: Person, with pageNumber: Int, success: @escaping (_ tallies: [LightTally]) -> (Void), failure: @escaping (NetworkError) -> (Void)) {
        
        guard let id = representative.id,
            let url = URL(string: "\(Constants.VOTES_URL)\(id)/votes?id=\(id)&page=\(pageNumber)") else {
                failure(.invalidURL)
                return
        }
        
        let session: URLSession = URLSession.shared
        let request = URLRequest(url: url, requestType: .get)
        
        let task: URLSessionDataTask = session.dataTask(with: request as URLRequest) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                if let error = NetworkError.error(for: httpResponse.statusCode) {
                    failure(error)
                }
            }

            if let data = data {
                var obj:[String: AnyObject]?
                do {
                    obj = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject]
                } catch {
                    failure(.invalidSerialization)
                }
                
                if let tallies = obj?["data"]?["voting_record"] as? [[String: AnyObject]] {
                    let lightTallies = tallies.map({
                        LightTally(json: $0)
                    })
                    DispatchQueue.main.async(execute: {
                        success(lightTallies)
                    })
                }
            }
        }
        task.resume()
    }
    
    static func fetchTally(for lightTally: LightTally, success: @escaping (Tally) -> (Void), failure: @escaping (NetworkError) -> (Void)) {
        
        guard let id = lightTally.id,
            let url = URL(string: "\(Constants.TALLY_URL)\(id)") else {
                failure(.invalidURL)
                return
        }
        
        let session: URLSession = URLSession.shared
        let request = URLRequest(url: url, requestType: .get)
        
        let task: URLSessionDataTask = session.dataTask(with: request as URLRequest) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                if let error = NetworkError.error(for: httpResponse.statusCode) {
                    failure(error)
                }
            }
            
            if let data = data {
                var obj:[String: AnyObject]?
                do {
                    obj = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject]
                } catch {
                    failure(.invalidSerialization)
                }
                
                if let obj = obj {
                   let tally = Tally(json: obj)
                    DispatchQueue.main.async(execute: {
                        success(tally)
                    })
                }
            }
        }
        task.resume()
    }
    
    static func fetchBill(from billId: Int, success: @escaping (Bill) -> (Void), failure: @escaping (NetworkError) -> (Void)) {
        
        guard let url = URL(string: "\(Constants.BILL_URL)\(billId)") else {
            failure(.invalidURL)
            return
        }
        
        let session: URLSession = URLSession.shared
        let request = URLRequest(url: url, requestType: .get)
        
        let task: URLSessionDataTask = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            if let httpResponse = response as? HTTPURLResponse {
                if let error = NetworkError.error(for: httpResponse.statusCode) {
                    failure(error)
                }
            }
            
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
        }
        task.resume()
    }
    
    static func fetchUserVotingRecord(success: @escaping ([LightTally]) -> (Void), failure: @escaping (NetworkError) -> (Void)) {
        
        guard let url = URL(string: Constants.YOUR_VOTES_URL) else {
            failure(.invalidURL)
            return
        }
        
        let session: URLSession = URLSession.shared
        let request = URLRequest(url: url, requestType: .get)
        
        let task: URLSessionDataTask = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            if let httpResponse = response as? HTTPURLResponse {
                if let error = NetworkError.error(for: httpResponse.statusCode) {
                    failure(error)
                }
            }
            
            if let data = data {
                var obj:[String: AnyObject]?
                do {
                    obj = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject]
                } catch {
                    failure(.invalidSerialization)
                }
                
                if let tallies = obj?["data"]?["voting_record"] as? [[String: AnyObject]] {
                    let lightTallies = tallies.map({
                        LightTally(json: $0)
                    })
                    DispatchQueue.main.async(execute: {
                        success(lightTallies)
                    })
                }
            }
        }
        task.resume()
    }
    
    static func createUserTally(with voteValue: VoteValue, tallyID: Int, success: @escaping (LightTally) -> (Void), failure: @escaping (NetworkError) -> (Void)) {
        
        let body: [String: [String: AnyObject]] = ["vote": ["tally_id": tallyID as AnyObject,
                                                  "value": voteValue.rawValue as AnyObject
                                                 ]
                                        ]
        
        guard let url = URL(string: Constants.YOUR_VOTES_CREATE_URL) else {
            failure(.invalidURL)
            return
        }
        
        let session: URLSession = URLSession.shared
        let request = URLRequest(url: url, requestType: .post, body: body)
        
        let task: URLSessionDataTask = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            if let httpResponse = response as? HTTPURLResponse {
                if let error = NetworkError.error(for: httpResponse.statusCode) {
                    failure(error)
                }
            }
            
            if let data = data {
                var obj:[String: AnyObject]?
                do {
                    obj = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject]
                } catch {
                    failure(.invalidSerialization)
                }
                
                if let obj = obj {
                   let tally =  LightTally(json: obj)
                    DispatchQueue.main.async(execute: {
                        success(tally)
                    })
                }
            }
        }
        task.resume()
    }
    
    static func fetchUserTally(tallyID: Int, success: @escaping (LightTally) -> (Void), failure: @escaping (NetworkError) -> (Void)) {
        
        guard let url = URL(string: "\(Constants.YOUR_VOTES_INDIVIDUAL_VOTE_URL)\(tallyID)") else {
            failure(.invalidURL)
            return
        }
        
        let session: URLSession = URLSession.shared
        let request = URLRequest(url: url, requestType: .get)
        
        let task: URLSessionDataTask = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            if let httpResponse = response as? HTTPURLResponse {
                if let error = NetworkError.error(for: httpResponse.statusCode) {
                    failure(error)
                }
            }
            
            if let data = data {
                var obj:[String: AnyObject]?
                do {
                    obj = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject]
                } catch {
                    failure(.invalidSerialization)
                }
                
                if let obj = obj {
                    let tally =  LightTally(json: obj)
                    DispatchQueue.main.async(execute: {
                        success(tally)
                    })
                }
            }
        }
        task.resume()
    }

    
    static func updateUserTally(with voteValue: VoteValue, tallyID: Int, success: @escaping (LightTally) -> (Void), failure: @escaping (NetworkError) -> (Void)) {
        
        let body: [String: [String: AnyObject]] = ["vote": [
                                                            "value": voteValue.rawValue as AnyObject
                                                            ]
                                                   ]
        
        guard let url = URL(string: "\(Constants.YOUR_VOTES_INDIVIDUAL_VOTE_URL)\(tallyID)") else {
            failure(.invalidURL)
            return
        }
        
        let session: URLSession = URLSession.shared
        let request = URLRequest(url: url, requestType: .put, body: body)
        
        let task: URLSessionDataTask = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            if let httpResponse = response as? HTTPURLResponse {
                if let error = NetworkError.error(for: httpResponse.statusCode) {
                    failure(error)
                }
            }
            
            if let data = data {
                var obj:[String: AnyObject]?
                do {
                    obj = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject]
                } catch {
                    failure(.invalidSerialization)
                }
                
                if let obj = obj {
                    let tally =  LightTally(json: obj)
                    DispatchQueue.main.async(execute: {
                        success(tally)
                    })
                }
            }
        }
        task.resume()
    }
    
    static func deleteUserTally(tallyID: Int, success: @escaping (Bool) -> (Void), failure: @escaping (NetworkError) -> (Void)) {
        
        guard let url = URL(string: "\(Constants.YOUR_VOTES_INDIVIDUAL_VOTE_URL)\(tallyID)") else {
            failure(.invalidURL)
            return
        }
        
        let session: URLSession = URLSession.shared
        let request = URLRequest(url: url, requestType: .delete)
        
        let task: URLSessionDataTask = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            if let httpResponse = response as? HTTPURLResponse {
                if let error = NetworkError.error(for: httpResponse.statusCode) {
                    failure(error)
                }
            }
            
            if let data = data {
                var obj:[String: AnyObject]?
                do {
                    obj = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject]
                } catch {
                    failure(.invalidSerialization)
                }
                
                if let obj = obj?["ok"] as? Bool {
                    DispatchQueue.main.async(execute: {
                        success(obj)
                    })
                }
            }
        }
        task.resume()
    }
    
    static func postKratosAnalyticEvent(with event: KratosAnalytics.ContactAnalyticType, success: @escaping (Bool) -> (Void), failure: @escaping (NetworkError) -> (Void)) {
        guard let url = URL(string: Constants.YOUR_ACTION_URL) else {
            failure(.invalidURL)
            return
        }
        let analyticAction = KratosAnalytics.shared
        
        if let body = analyticAction.toDict(with: event) {
           let session: URLSession = URLSession.shared
           let request = URLRequest(url: url, requestType: .post, body: body)
            
            let task: URLSessionDataTask = session.dataTask(with: request as URLRequest) { (data, response, error) in
                
                if let httpResponse = response as? HTTPURLResponse {
                    if let error = NetworkError.error(for: httpResponse.statusCode) {
                        failure(error)
                    }
                }
                
                if let data = data {
                    var obj:[String: AnyObject]?
                    do {
                        obj = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject]
                    } catch {
                        failure(.invalidSerialization)
                    }
                    
                    if let obj = obj?["ok"] as? Bool {
                        DispatchQueue.main.async(execute: {
                            success(obj)
                        })
                    }
                }
            }
            task.resume()
        }
    }
}

