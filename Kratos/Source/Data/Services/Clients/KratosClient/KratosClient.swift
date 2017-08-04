//
//  KratosClient.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/26/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

struct KratosClient {
    
    let token: String?
    
    fileprivate func baseURL(for target: KratosTarget) -> String {
        return Configuration.kratos.url
    }
    
    private static let basicAuthToken: String = {
        "\(Configuration.kratos.clientId): \(Configuration.kratos.clientSecret)"
    }()
    
    private var basicHeader: [String: String] {
        return ["Authorization": "basic \(KratosClient.basicAuthToken)"]
    }
    
    private var bearerHeader: [String: String]? {
        guard let token = token else { return nil }
        return ["Authorization": "Bearer \(token)"]
    }
    
    fileprivate var authorizationHeader: [String: String] {
        return bearerHeader ?? basicHeader
    }
}

extension KratosClient: MicroClient {
    func buildRequest(_ target: KratosTarget) -> Observable<Data> {
        let url = self.baseURL(for: target) + target.path
        print("req --> \(url)")
        return Observable.create { observer in
            let request = Alamofire.request(
                url,
                method: target.method,
                parameters: target.parameters,
                encoding: URLEncoding.httpBody,
                headers: self.authorizationHeader
                )
                .responseData { response in
                    if let result = response.result.value {
                        observer.onNext(result)
                    } else if let error = response.result.error {
                        observer.onError(error)
                    }
                    observer.onCompleted()
            }
            
            return Disposables.create {
                request.cancel()
            }
        }
    }
}
