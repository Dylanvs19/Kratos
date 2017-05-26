//
//  APIService.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/31/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import Foundation

struct APIService {
    
    //MARK: Sign In
    
    static func register(_ user: User, with password: String, success: @escaping (User) -> (), failure: @escaping (KratosError) -> ()) {
        
        // URL Components
        guard let url = URL(string: Constants.REGISTRATION_URL) else {
            failure(.invalidURL(error:nil))
            return
        }
        if let dict = user.toJson() {
            
            let session: URLSession = URLSession.shared
            let request = URLRequest(url: url, requestType: .post, body: dict, addToken: false)
            
            let task: URLSessionDataTask = session.dataTask(with: request) { (data, response, error) in
                
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
                
                if let httpResponse = response as? HTTPURLResponse {
                    if let error = KratosError.error(for: httpResponse.statusCode, error: obj?["errors"] as? [[String: String]]) {
                        failure(error)
                    }
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
    
    static func forgotPassword(with email: String, success: @escaping (Bool) -> (), failure: @escaping (KratosError) -> ()) {
        
        // URL Components
        guard let url = URL(string: Constants.FORGOT_PASSWORD_URL) else {
            failure(.invalidURL(error:nil))
            return
        }
        let dict =  ["email": email.lowercased() as AnyObject]
        
        let session: URLSession = URLSession.shared
        let request = URLRequest(url: url, requestType: .post, body: dict, addToken: false)
        
        let task: URLSessionDataTask = session.dataTask(with: request) { (data, response, error) in
            
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
            
            if let httpResponse = response as? HTTPURLResponse {
                if let error = KratosError.error(for: httpResponse.statusCode, error: obj?["errors"] as? [[String: String]]) {
                    failure(error)
                }
            }
            
            if obj != nil {
                DispatchQueue.main.async(execute: {
                    success(true)
                })
            }
        }
        task.resume()
    }
    
    //MARK: Feedback
    
    static func fetchFeedback(success: @escaping ([String]) -> (), failure: @escaping (KratosError) -> ()) {
        
        // URL Components
        guard let url = URL(string: Constants.FEEDBACK_URL) else {
            failure(.invalidURL(error:nil))
            return
        }
        
        let session: URLSession = URLSession.shared
        let request = URLRequest(url: url, requestType: .get)
        
        let task: URLSessionDataTask = session.dataTask(with: request) { (data, response, error) in
            
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
            
            if let httpResponse = response as? HTTPURLResponse {
                if let error = KratosError.error(for: httpResponse.statusCode, error: obj?["errors"] as? [[String: String]]) {
                    failure(error)
                }
            }
            
            if let obj = obj?["questions"] as? [String] {
                DispatchQueue.main.async(execute: {
                    success(obj)
                })
            }
        }
        task.resume()
    }
    
    static func postFeedback(with questions: [String: String], success: @escaping (Bool) -> (), failure: @escaping (KratosError) -> ()) {
        
        // URL Components
        guard let url = URL(string: Constants.FEEDBACK_URL) else {
            failure(.invalidURL(error:nil))
            return
        }
        guard let id = Datastore.shared.user?.id else {
            failure(.appSideError(error: nil))
            return
        }
        let params = ["user-id" : id as AnyObject,
                      "answers" : questions as AnyObject] as [String: AnyObject]
        
        let session: URLSession = URLSession.shared
        let request = URLRequest(url: url, requestType: .post, body: params)
        
        let task: URLSessionDataTask = session.dataTask(with: request) { (data, response, error) in
            
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
            
            if let httpResponse = response as? HTTPURLResponse {
                if let error = KratosError.error(for: httpResponse.statusCode, error: obj?["errors"] as? [[String: String]]) {
                    failure(error)
                }
            }
            
            if obj != nil {
                DispatchQueue.main.async(execute: {
                    success(true)
                })
            }
        }
        task.resume()
    }

    //MARK: User
    
    static func fetchUser(_ success: @escaping (User) -> (), failure: @escaping (KratosError) -> ()) {
        // URL Components
        guard let url = URL(string: Constants.USER_URL) else {
            failure(.invalidURL(error:nil))
            return
        }
        
        let session: URLSession = URLSession.shared
        let request = URLRequest(url: url, requestType: .get)
        
        let task: URLSessionDataTask = session.dataTask(with: request) { (data, response, error) in
            
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
            
            if let httpResponse = response as? HTTPURLResponse {
                if let error = KratosError.error(for: httpResponse.statusCode, error: obj?["errors"] as? [[String: String]]) {
                    failure(error)
                }
            }
            
            if let obj = obj,
                let user = User(json: obj, pureUser: true) {
                DispatchQueue.main.async(execute: {
                    success(user)
                })
            }
        }
        task.resume()
    }
    
    static func logIn(with email: String, password: String, success: @escaping (User) -> (), failure: @escaping (KratosError) -> ()) {
        let parameters: [String: AnyObject] = [
            "email": email.lowercased() as AnyObject,
            "password": password as AnyObject
        ]
        
        let dict: [String: Any] = ["session": parameters]
        
        guard let url = URL(string: Constants.LOGIN_URL) else {
            failure(.invalidURL(error:nil))
            return
        }
        
        let session: URLSession = URLSession.shared
        let request = URLRequest(url: url, requestType: .post, body: dict, addToken: false)
        
        let task: URLSessionDataTask = session.dataTask(with: request as URLRequest) { (data, response, error) in
            var obj:[String: AnyObject]?
            
            guard let data = data else {
                failure(.nilData)
                return
            }
            
            do {
                obj = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject]
            } catch {
                failure(.invalidSerialization)
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if let error = KratosError.error(for: httpResponse.statusCode, error: obj?["errors"] as? [[String: String]]) {
                    failure(error)
                }
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
    
    static func update(with user: User, success: @escaping (User) -> (), failure: @escaping (KratosError) -> ()) {
        
        if let dict = user.toJsonForUpdate() {
            
            guard let url = URL(string: Constants.USER_URL) else {
                failure(.invalidURL(error:nil))
                return
            }
            
            let session: URLSession = URLSession.shared
            let request = URLRequest(url: url, requestType: .post, body: dict)
            
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
                
                if let httpResponse = response as? HTTPURLResponse {
                    if let error = KratosError.error(for: httpResponse.statusCode, error: obj?["errors"] as? [[String: String]]) {
                        failure(error)
                    }
                }
                
                if let obj = obj,
                    let user = User(forUpdate: obj) {
                    DispatchQueue.main.async(execute: {
                        success(user)
                    })
                }
            }
            task.resume()
        }
    }
    
    static func fetchUserVotingRecord(success: @escaping ([LightTally]) -> (Void), failure: @escaping (KratosError) -> (Void)) {
        
        guard let url = URL(string: Constants.YOUR_VOTES_URL) else {
            failure(.invalidURL(error:nil))
            return
        }
        
        let session: URLSession = URLSession.shared
        let request = URLRequest(url: url, requestType: .get)
        
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
            
            if let httpResponse = response as? HTTPURLResponse {
                if let error = KratosError.error(for: httpResponse.statusCode, error: obj?["errors"] as? [[String: String]]) {
                    failure(error)
                }
            }
            
            if let tallies = obj?["data"]?["voting_record"] as? [[String: AnyObject]] {
                let lightTallies = tallies.map({
                    LightTally(json: $0)
                }).flatMap({$0})
                DispatchQueue.main.async(execute: {
                    success(lightTallies)
                })
            }
        }
        task.resume()
    }
    
    static func createUserTally(with voteValue: VoteValue, tallyID: Int, success: @escaping (LightTally) -> (Void), failure: @escaping (KratosError) -> (Void)) {
        
        let body: [String: [String: AnyObject]] = ["vote": ["tally_id": tallyID as AnyObject,
                                                            "value": voteValue.rawValue as AnyObject
            ]
        ]
        
        guard let url = URL(string: Constants.YOUR_VOTES_CREATE_URL) else {
            failure(.invalidURL(error:nil))
            return
        }
        
        let session: URLSession = URLSession.shared
        let request = URLRequest(url: url, requestType: .post, body: body)
        
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
            
            if let httpResponse = response as? HTTPURLResponse {
                if let error = KratosError.error(for: httpResponse.statusCode, error: obj?["errors"] as? [[String: String]]) {
                    failure(error)
                }
            }
            
            
            if let obj = obj,
                let tally =  LightTally(json: obj) {
                DispatchQueue.main.async(execute: {
                    success(tally)
                })
            }
        }
        task.resume()
    }
    
    static func fetchUserTally(tallyID: Int, success: @escaping (LightTally) -> (Void), failure: @escaping (KratosError) -> (Void)) {
        
        guard let url = URL(string: "\(Constants.YOUR_VOTES_INDIVIDUAL_VOTE_URL)\(tallyID)") else {
            failure(.invalidURL(error:nil))
            return
        }
        
        let session: URLSession = URLSession.shared
        let request = URLRequest(url: url, requestType: .get)
        
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
            
            if let httpResponse = response as? HTTPURLResponse {
                if let error = KratosError.error(for: httpResponse.statusCode, error: obj?["errors"] as? [[String: String]]) {
                    failure(error)
                }
            }
            
            if let obj = obj,
                let tally =  LightTally(json: obj) {
                DispatchQueue.main.async(execute: {
                    success(tally)
                })
            }
        }
        task.resume()
    }
    
    
    static func updateUserTally(with voteValue: VoteValue, tallyID: Int, success: @escaping (LightTally) -> (Void), failure: @escaping (KratosError) -> (Void)) {
        
        let body: [String: [String: AnyObject]] = ["vote": [
            "value": voteValue.rawValue as AnyObject
            ]
        ]
        
        guard let url = URL(string: "\(Constants.YOUR_VOTES_INDIVIDUAL_VOTE_URL)\(tallyID)") else {
            failure(.invalidURL(error:nil))
            return
        }
        
        let session: URLSession = URLSession.shared
        let request = URLRequest(url: url, requestType: .put, body: body)
        
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
            
            if let httpResponse = response as? HTTPURLResponse {
                if let error = KratosError.error(for: httpResponse.statusCode, error: obj?["errors"] as? [[String: String]]) {
                    failure(error)
                }
            }
            
            if let obj = obj,
                let tally =  LightTally(json: obj) {
                DispatchQueue.main.async(execute: {
                    success(tally)
                })
            }
        }
        task.resume()
    }
    
    static func deleteUserTally(tallyID: Int, success: @escaping (Bool) -> (Void), failure: @escaping (KratosError) -> (Void)) {
        
        guard let url = URL(string: "\(Constants.YOUR_VOTES_INDIVIDUAL_VOTE_URL)\(tallyID)") else {
            failure(.invalidURL(error:nil))
            return
        }
        
        let session: URLSession = URLSession.shared
        let request = URLRequest(url: url, requestType: .delete)
        
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
            
            if let httpResponse = response as? HTTPURLResponse {
                if let error = KratosError.error(for: httpResponse.statusCode, error: obj?["errors"] as? [[String: String]]) {
                    failure(error)
                }
            }
            
            if let obj = obj?["ok"] as? Bool {
                DispatchQueue.main.async(execute: {
                    success(obj)
                })
            }
        }
        task.resume()
    }
    
    //MARK: Representatives
    
    static func fetchRepresentatives(for state: String, and district: Int, success: @escaping ([Person]) -> (), failure: @escaping (KratosError) -> ()) {
        
        guard let url = URL(string: "\(Constants.REPRESENTATIVES_URL)\(state)/\(district)") else {
            failure(.invalidURL(error:nil))
            return
        }
        
        let session: URLSession = URLSession.shared
        let request = URLRequest(url: url, requestType: .get)
        
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
            
            if let httpResponse = response as? HTTPURLResponse {
                if let error = KratosError.error(for: httpResponse.statusCode, error: obj?["errors"] as? [[String: String]]) {
                    failure(error)
                }
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
        task.resume()
    }
    
    static func fetchPerson(for personID: Int, success: @escaping (Person) -> (), failure: @escaping (KratosError) -> ()) {
        
        guard let url = URL(string: "\(Constants.PERSON_URL)\(personID)") else {
            failure(.invalidURL(error:nil))
            return
        }
        
        let session: URLSession = URLSession.shared
        let request = URLRequest(url: url, requestType: .get)
        
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
            
            if let httpResponse = response as? HTTPURLResponse {
                if let error = KratosError.error(for: httpResponse.statusCode, error: obj?["errors"] as? [[String: String]]) {
                    failure(error)
                }
            }
            
            if let obj = obj,
               let person = Person(json: obj) {
                DispatchQueue.main.async(execute: {
                    success(person)
                })
            }
        }
        task.resume()
    }
    
    //MARK: Tallies
    
    static func fetchTallies(for personID: Int, with pageNumber: Int, success: @escaping (_ tallies: [LightTally]) -> (Void), failure: @escaping (KratosError) -> (Void)) {
        
        guard let url = URL(string: "\(Constants.VOTES_URL)\(personID)/votes?id=\(personID)&page=\(pageNumber)") else {
                failure(.invalidURL(error: nil))
                return
        }
        
        let session: URLSession = URLSession.shared
        let request = URLRequest(url: url, requestType: .get)
        
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
            
            if let httpResponse = response as? HTTPURLResponse {
                if let error = KratosError.error(for: httpResponse.statusCode, error: obj?["errors"] as? [[String: String]]) {
                    failure(error)
                }
            }
            
            if let tallies = obj?["data"]?["voting_record"] as? [[String: AnyObject]] {
                let lightTallies = tallies.map({
                    LightTally(json: $0)
                }).flatMap({$0})
                DispatchQueue.main.async(execute: {
                    success(lightTallies)
                })
            }
        }
        task.resume()
    }
    
    static func fetchTally(for lightTallyID: Int, success: @escaping (Tally) -> (Void), failure: @escaping (KratosError) -> (Void)) {
        
        guard let url = URL(string: "\(Constants.TALLY_URL)\(lightTallyID)") else {
                failure(.invalidURL(error:nil))
                return
        }
        
        let session: URLSession = URLSession.shared
        let request = URLRequest(url: url, requestType: .get)
        
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
            
            if let httpResponse = response as? HTTPURLResponse {
                if let error = KratosError.error(for: httpResponse.statusCode, error: obj?["errors"] as? [[String: String]]) {
                    failure(error)
                }
            }
            
            if let obj = obj,
               let tally = Tally(json: obj) {
                DispatchQueue.main.async(execute: {
                    success(tally)
                })
            }
        }
        task.resume()
    }
    
    //MARK: Bills
    
    static func fetchBill(from billId: Int, success: @escaping (Bill) -> (Void), failure: @escaping (KratosError) -> (Void)) {
        
        guard let url = URL(string: "\(Constants.BILL_URL)\(billId)") else {
            failure(.invalidURL(error:nil))
            return
        }
        
        let session: URLSession = URLSession.shared
        let request = URLRequest(url: url, requestType: .get)
        
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
            
            if let httpResponse = response as? HTTPURLResponse {
                if let error = KratosError.error(for: httpResponse.statusCode, error: obj?["errors"] as? [[String: String]]) {
                    failure(error)
                }
            }
            
            if let obj = obj,
                let bill = Bill(json: obj) {
                DispatchQueue.main.async(execute: {
                    success(bill)
                })
            }
        }
        task.resume()
    }
    
    static func fetchSponsoredBills(for personID: Int, with pageNumber: Int, success: @escaping ([Bill]) -> (Void), failure: @escaping (KratosError) -> (Void)) {
        
        guard let url = URL(string: "\(Constants.PERSON_URL)/\(personID)/bills?id=\(personID)&page=\(pageNumber)") else {
            failure(.invalidURL(error:nil))
            return
        }
        
        let session: URLSession = URLSession.shared
        let request = URLRequest(url: url, requestType: .get)
        
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
            
            if let httpResponse = response as? HTTPURLResponse {
                if let error = KratosError.error(for: httpResponse.statusCode, error: obj?["errors"] as? [[String: String]]) {
                    failure(error)
                }
            }
            
            if let bills = obj?["data"] as? [[String: AnyObject]] {
                let lightBills = bills.map({
                    Bill(json: $0)
                }).flatMap({$0})
                DispatchQueue.main.async(execute: {
                    success(lightBills)
                })
            }
        }
        task.resume()
    }

    //MARK: Analytics
    
    static func postKratosAnalyticEvent(with event: KratosAnalytics.ContactAnalyticType, success: @escaping (Bool) -> (Void), failure: @escaping (KratosError) -> (Void)) {
        guard let url = URL(string: Constants.YOUR_ACTION_URL) else {
            failure(.invalidURL(error:nil))
            return
        }
        let analyticAction = KratosAnalytics.shared
        
        guard let body = analyticAction.toDict(with: event) else {
            failure(.appSideError(error: nil))
            return
        }
        
        let session: URLSession = URLSession.shared
        let request = URLRequest(url: url, requestType: .post, body: body)
        
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
            
            if let httpResponse = response as? HTTPURLResponse {
                if let error = KratosError.error(for: httpResponse.statusCode, error: obj?["errors"] as? [[String: String]]) {
                    failure(error)
                }
            }
            
            if let obj = obj?["ok"] as? Bool {
                DispatchQueue.main.async(execute: {
                    success(obj)
                })
            }
        }
        task.resume()
    }
}
