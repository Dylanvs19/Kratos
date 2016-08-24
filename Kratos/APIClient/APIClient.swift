//
//  APIClient.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/31/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import Foundation

struct APIClient {
    
    func loadVotes(for representative: Representative, success: ([Vote]) -> (Void), failure: (NSError?) -> (Void)) {
        
        let session: NSURLSession = NSURLSession.sharedSession()
        
        guard let id = representative.id,
            let url = NSURL(string: "\(Constants.REPRESENTATIVE_LEGISLATION_CONSTANT)\(id)/votes") else {
                failure(nil)
                return
        }
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
            if let data = data {
                do {
                    let obj = try NSJSONSerialization.JSONObjectWithData(data, options: [])
                    if let obj = obj as? [[String: AnyObject]] {
                        let legislationArray = obj.map({
                            Vote(json: $0)
                        })
                        dispatch_async(dispatch_get_main_queue(), {
                            success(legislationArray)
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
    }
    
    func loadRepresentatives(from streetAddress: StreetAddress, success: ([[String: AnyObject]]) -> (Void), failure: (NSError?) -> (Void)) {
        
        let session: NSURLSession = NSURLSession.sharedSession()
        let url = NSURL(string: Constants.ADDRESS_API_CONSTANT)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let streetAddress = Datastore.sharedDatastore.streetAdress?.dictionaryFormat {
            do {
                let jsonData = try NSJSONSerialization.dataWithJSONObject(streetAddress, options: [])
                request.HTTPBody = jsonData
                
                let task: NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
                    
                    if let data = data {
                        do {
                            let obj = try NSJSONSerialization.JSONObjectWithData(data, options: [])
                            if let obj = obj as? [[String: AnyObject]] {
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
}