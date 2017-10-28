//
//  KratosClient.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/26/17.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
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
                encoding: target.parameterEncoding,
                headers: self.authorizationHeader
                )
                .responseData { response in
                    defer { observer.onCompleted() }
                    
                    guard let statusCode = response.response?.statusCode,
                        (200...299).contains(statusCode) else {
                            observer.onError(self.decodeError(from: response))
                            return
                    }
                    
                    if let result = response.result.value {
                        observer.onNext(result)
                    } else {
                        observer.onError(KratosError.unknown)
                    }
            }
            
            return Disposables.create {
                request.cancel()
            }
        }
    }
    
    private func decodeError(from response: DataResponse<Data>) -> KratosError {
        if let error = response.result.error,
           let statusCode = response.response?.statusCode {
            return KratosError.server(error: error, statusCode: statusCode)
        }
        
        guard let data = response.result.value,
              let json = try? JSONSerialization.jsonObject(with: data, options: []),
              let result = json as? JSONObject,
              let statusCode = response.response?.statusCode else { return KratosError.unknown }
        return KratosError.error(from: result, statusCode: statusCode)
    }
}
