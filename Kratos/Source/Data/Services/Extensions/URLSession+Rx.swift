//
//  KratosAPI+Rx.swift
//  Kratos
//
//  Created by Dylan Straughan on 5/7/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import RxSwift

extension Reactive where Base: URLSession {

    func send(client: Client, target: KratosTarget) -> Observable<Data> {
        return Observable.create { observer in
            
            var url: URL?
            if target.isSameType(as: .url(url: "")) {
                url = URL(string: target.path)
            } else {
                url = URL(string: "\(client.baseURL)\(target.path)")
            }
            
            guard let finalURL = url else {
                observer.onError(KratosError.invalidURL(error: nil))
                return Disposables.create()
            }
            
            let request = URLRequest(url: finalURL, requestType: target.method, body: target.parameters, addToken: target.addToken)
            //print("Request: \(request), Method: \(String(describing: request.httpMethod)), Body: \(String(describing: target.parameters)), Headers: \(String(describing: request.allHTTPHeaderFields))")
            let task = self.base.dataTask(with: request) { (data, response, error) in
                
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                    observer.on(.error(KratosError.nonHTTPResponse(response: response)))
                    return
                }
                
                guard let data = data else {
                    observer.onError(KratosError.nilData)
                    return
                }
                
                guard 200...300 ~= statusCode else {
                    var error = [String: Any]()
                    if let errorDict = data.toJSON() as? [String: Any] {
                        error = errorDict
                    }
                    observer.onError(KratosError.error(for: statusCode, error: (error["errors"] as? [[String: String]])) ?? KratosError.unknown)
                    return
                }
                
                observer.onNext(data)
                observer.onCompleted()
            }
            task.resume()
            
            return Disposables.create { task.cancel() }
            
            }
        }
    }
