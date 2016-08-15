//
//  APIClient.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/31/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import Foundation

struct APIClient {
    
    func loadLegislation(from representative: Representative, onCompletion: ([Legislation]) -> (Void)) {
        
    }
    
    func loadRepresentatives(from streetAddress: StreetAddress, onCompletion: ([[String: AnyObject]]) -> (Void), errorCompletion: (NSError?) -> (Void)) {
        
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
                                    onCompletion(obj)
                                })
                            }
//                            if let httpResponse = response as? NSHTTPURLResponse {
//                                debugPrint("status code: \(httpResponse.statusCode)")
//                            }
                        } catch let error as NSError {
                            errorCompletion(error)
                        }
                    }
                    if error != nil {
                        errorCompletion(error)
                    }
                })
                
                task.resume()
                
            } catch let error as NSError {
                errorCompletion(error)
            }
        }

    }
    
}